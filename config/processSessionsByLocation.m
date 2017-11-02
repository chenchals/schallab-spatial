function [ ] = processSessionsByLocation(nhpConfig)
% function [ nhpSessions ] = processSessionsByLocation(nhpConfig)
%PROCESSSESSIONSBYLOCATION Process each recording session.
% See also PROCESSSESSIONS for input definition
%
%     Output: Written to session file and NOT a function output
%       nhpSessions: A struct.
%                    Fieldnames = session_name
%                    Each session field is a struct
%                    Example:
%                       nhpSessions struct with fields:
%                     **Field is a Session:
%                         darwin2016_02_15a: [1×1 struct]
%                         darwin2016_02_16a: [1×1 struct]
%                         darwin2016_02_19a: [1×1 struct]
%                     **Session:
%                          Darwin.darwin2016_02_15a
%                           struct with fields:
%                                           analysisDate: '04-Oct-2017 21:34:28'
%                                                session: '2016-02-15a'
%                                                   info: [1×27 table]
%                                             channelMap: [32×1 double]
%                                  ipsi_targetOnset_left: [1×1 struct]
%                                ipsi_responseOnset_left: [1×1 struct]
%                               contra_targetOnset_right: [1×1 struct]
%                             contra_responseOnset_right: [1×1 struct]
%                     **Session.Condition:
%                          Darwin.darwin2016_02_15a.ipsi_responseOnset_left
%                            struct with fields:
%                                           channelMap: [32×1 double]
%                                              sdfMean: [32×501 double]
%                             sdfPopulationZscoredMean: [32×501 double]
%                                       populationMean: 24.127
%                                        populationStd: 35.02
%                                             spikeIds: {32×1 cell}
%                                            sdfWindow: [1×501 double]
%                                              nTrials: 203
%                                             trialMap: [203×32 double]
%                                                  sdf: [6496×501 double]
%                                 sdfPopulationZscored: [6496×501 double]
%                                             rsquared: [32×32 double]
%
% See also PROCESSJOULE, PROCESSBROCA, PROCESSDARWIN, DOPLOT8

    nhp = nhpConfig.nhp;
    nhpSourceDir = nhpConfig.nhpSourceDir;
    excelFile = nhpConfig.excelFile;
    sheetName = nhpConfig.sheetName;
    nhpOutputDir = nhpConfig.nhpOutputDir;
    getSessions = nhpConfig.getSessions;
    dataModelName = nhpConfig.dataModelName;
    outcome = nhpConfig.outcome; %'saccToTarget';
    conditions = nhpConfig.conditions;
    distancesToCompute = nhpConfig.distancesToCompute;
    minTrialsPerCondition = nhpConfig.minTrialsPerCondition;
    % optional
    selectedTaskType = '';
    if isfield(nhpConfig, 'selectedTaskType')
       selectedTaskType = upper(nhpConfig.selectedTaskType);
       selectedTaskTypeToSave = selectedTaskType;
    end
        
    outputDir = nhpOutputDir;
    
    if ~exist(nhpOutputDir,'dir')
        mkdir(nhpOutputDir);
        nixUpdateAttribs(nhpOutputDir);
    end
    
    logger = Logger.getLogger(fullfile(nhpOutputDir,[nhp 'ProcessSessions.log']));
    errorLogger = Logger.getLogger(fullfile(nhpOutputDir,[nhp 'ProcessSessionsErrors.log']));
    
    % Read excel sheet
    nhpTable = readtable(excelFile, 'Sheet', sheetName);

    %remove empty rows
    nhpTable(strcmp(nhpTable.matPath,''),:) = [];
    nhpTable.date = datestr(nhpTable.date,'mm/dd/yyyy');
    nhpTable.ephysChannelMap = arrayfun(@(x) ...
        str2num(char(split(nhpTable.ephysChannelMap{x},', '))),...
        1:size(nhpTable,1),'UniformOutput',false)';   %#ok<ST2NM>
    
    nhpConfig.nhpTable = nhpTable;
    
    outputFile = fullfile(nhpOutputDir,[nhp 'Config.mat']);       
    save(outputFile, 'nhpConfig');

    sessionLocations = getSessions(nhpSourceDir, nhpTable);
    nhpConfig.sessions = sessionLocations;
      
    %nhpSessions = cell();

   for sessionIndex = 1:numel(sessionLocations)
       try
           sessionLocation = sessionLocations{sessionIndex};
           nhpInfo = nhpTable(sessionIndex,:);
           qualityOfSession = nhpInfo.qualityOfSession;
           if isempty(qualityOfSession)
               qualityOfSession = NaN; % lowest quality
           end
           %qualityDir = fullfile(outputDir,['quality_' num2str(qualityOfSession)]);
           qualityStr= ['Q' num2str(qualityOfSession)];
           
           % Seleted Task Type string
           if isempty(selectedTaskType)
               if numel(split(nhpInfo.paradigm,',')) > 1
                   error('The Excel info for session [%s] has paradigms [%s], since there is more than 1 paradigm, nhpConfig.selectedTaskType must be set to one of the paradigms',...
                       nhpInfo.session{1}, nhpInfo.paradigm{1});                  
               else                   
                   selectedTaskTypeToSave = upper(nhpInfo.paradigm{1});
               end
           end
           % Include probe number, selected taskType, quality in session name
           if find(strcmp('probeNo',nhpInfo.Properties.VariableNames))
               sessionName = [nhpInfo.session{1} '_probe' num2str(nhpInfo.probeNo) '_' selectedTaskTypeToSave '_' qualityStr];
           else
               sessionName = [nhpInfo.session{1} '_' selectedTaskTypeToSave '_' qualityStr];
           end
           
           % Save to taskType Dir for nhp
           oDir = fullfile(outputDir, selectedTaskTypeToSave);
            

            if isempty(sessionLocation)
                errorLogger.error(sprintf('Session %s has no datafiles. Using [ %s ] for spike file locations',...
                    sessionName, char(nhpInfo.matPath))); 
                continue
            end
                        
            multiSdf = struct();
            channelMap = nhpInfo.ephysChannelMap{1};
            logger.info(sprintf('Processing session %s',sessionName)); 
            if contains(lower(nhpInfo.chamberLoc),'left')
                ipsi = 'left';
            else
                ipsi = 'right';
            end
            % Create instance of MemoryTypeModel
            model = DataModel.newInstance(dataModelName, sessionLocation, channelMap);
                        
            multiSdf.analysisDate = datestr(now);
            multiSdf.session = sessionName;
            multiSdf.info = nhpInfo;
            multiSdf.channelMap = model.getChannelMap;
            
            for c = 1:numel(conditions)
                currCondition = conditions{c};
                alignOn = currCondition{1};
                targetLocations = currCondition{2};
                sdfWindow = currCondition{3};
                %check minTrialsPerCondition is satisfied
                selectedTrialsByLocation = checkMinTrialsPerCondition(model, outcome, targetLocations, minTrialsPerCondition,selectedTaskType);
                for tLoc = 1:numel(targetLocations)
                    currTargetLocation = targetLocations{tLoc};
                    trialList = selectedTrialsByLocation{tLoc};
                    if numel(trialList) > minTrialsPerCondition
                    condStr = [alignOn sprintf('_%d',currTargetLocation)] ;                    
                    logger.info(sprintf('Doing condition: outcome %s, alignOn %s, targetLocations %s sdfWindow [%s]',...
                        outcome, alignOn, num2str(currTargetLocation), num2str(sdfWindow)));
                    % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
                    [~, multiSdf.(condStr)] = model.getMultiUnitSdf(trialList, alignOn, sdfWindow);
                    else
                    logger.warn(sprintf('Number of trials [%d] for outcome %s, targetLocations %s is below minTrialsPerCondition [%d]',...
                        numel(trialList), outcome, num2str(currTargetLocation), num2str(minTrialsPerCondition)));
                    end
                end
            end
             % To use Kalebs klNormRespv2: 
            conds = fieldnames(multiSdf);
            % to use bl option conditions have to be ordered with targetAligned being the first
            conds = conds(~cellfun(@isempty,regexp(conds,'targetOnset|responseOnset','match')));
            % order is ipsi_targetOnset,ipsi_responseOnset,...
            % contra_targetOnset, contra_responseOnset
            conds = flipud(sortrows(conds));
            % Aggregate all condition sdfs into cellArray of cells
            respAlign = cellfun(@(x) multiSdf.(char(x)).sdfMean,conds,'UniformOutput',false);
            % Aggregate all condition sdfWindow into cellArray of cells
            respTimes = cellfun(@(x) multiSdf.(char(x)).sdfWindow,conds,'UniformOutput',false);
            % Normalize with ztr option 
            normRespZtr =  klNormRespv2(respAlign,respTimes,'ztr','-r',respTimes);
            for ii = 1:numel(conds)
                condStr = conds{ii};
                sdfMeanZtr = normRespZtr{ii};
                multiSdf.(condStr).sdfMeanZtr = sdfMeanZtr;                  
            end
            % Distance computation
            % do tandem of 2 alignOn conditions for each location condition
                       
            clearvars conds respAlign respTimes normRespZtr
            oFile = fullfile(oDir,[multiSdf.session '.mat']);
            logger.info(sprintf('Saving processed session to %s...',oFile));
            saveProcesssedSession(multiSdf, oFile);
            %nhpSessions=multiSdf;
            %plotAndSaveFig(multiSdf, oDir, logger, errorLogger);
            
        catch me
            % log the error/exception causing failure and continue
            disp(me)
            logger.error(me);
            errorLogger.error(sprintf('Error processing session %s. Using [ %s ] for spike file locations',...
                nhpInfo.session{1}, char(nhpInfo.matPath)));
            errorLogger.error(me);
        end
    end
end

%% Plot and save Figures
function [] = plotAndSaveFig(currSession, nhpOutputDir, logger, errorLogger)
    plotsDir = [nhpOutputDir filesep 'figs'];
    if ~exist(plotsDir,'dir')
        mkdir(plotsDir)
        nixUpdateAttribs(plotsDir);        
    end
    figH = [];
    try
        sessionLabel = currSession.session;
        figH = doPlot8R(currSession,sessionLabel, {'jet' 'cool'}, plotsDir);
    catch me
        % log the error/exception causing failure and continue
        logger.error(me);
        errorLogger.error(me);
    end
    if ~ isempty(figH)
        delete(figH);
    end
end

%% Save processed session
function saveProcesssedSession(currSession, oFile)   %#ok<INUSL>
    [d,~,~] = fileparts(oFile);
    if ~exist(d,'dir')
        mkdir(d);
        nixUpdateAttribs(d);
    end
    save(oFile, '-struct', 'currSession' );
    nixUpdateAttribs(oFile);
end

%% For converting cell array to string (only char are converted)
function [ condStr ] = convertToChar(condCellArray, ipsiSide)
    indexChars = cellfun(@(x) ischar(x),condCellArray);
    charStr = char(join(condCellArray(indexChars),'_'));
    if contains(charStr,ipsiSide)
        condStr = ['ipsi_' charStr];
    else
        condStr = ['contra_' charStr];
    end
end

function [selectedTrialsByLocation] = checkMinTrialsPerCondition(model, outcome, locationCondition, minTrials, selectedTaskType)
        selectedTrialsByLocation = model.getTrialList(outcome,locationCondition,selectedTaskType);
        
        if sum(~cell2mat(arrayfun(@(x) numel(x{1})>minTrials,...
                selectedTrialsByLocation(arrayfun(@(x) numel(x{1})>0,selectedTrialsByLocation)),...
                'UniformOutput',false)))
            throw(MException('processSessions:checkMinTrialsPerCondition', 'MinTrialsPerCondition %d, failed!',minTrials));

        end
end
