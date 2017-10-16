function [ ] = processSessions(nhpConfig)
% function [ nhpSessions ] = processSessions(nhpConfig)
%PROCESSSESSIONS Process each recording session.
%   Inputs:
%     nhpConfig: A structured variable with fields that define how to
%     process matalb datafile for this NHP.
%     struct with fields:
%               nhp: 'Joule'                    NHP name. Used as prefix for output filename
%      nhpSourceDir: '[full-path]/Joule'        Fullpath to source data folder
%         excelFile: '[full-path]/excel.xlsx'   Column names correspond to property names [**DO NOT CHANGE**]
%         sheetName: 'Jo'                       Sheet name of excel file for this NHP
%      nhpOutputDir: '[full-path]/output/Joule' Fullpath to folder for processed data
%       getSessions: @getSessions               A function handle to get sessions for processing
%                    Note: Used column names in excel sheet above to derive
%                    the location of sessions. The output of this function must be
%                       (1) cellstr : Each element is a fullpath to a .mat file.
%                                     Single mat file contains data for all channels
%                                 {'full-path-session-1-file',...,  'full-path-session-n-file'}
%                       (2) cell array of cellstr : Each element is a cellstr.
%                                     Each cellstr contains fullpath to all channelNN.mat files.
%                                     Each file contains data for a single channel
%                                {
%                                   {'full-path-channel-1-file',...,  'full-path-channel-n-file'}
%                                   ...
%                                   {'full-path-channel-1-file',...,  'full-path-channel-n-file'}
%                                }
%     dataModelName: DataModel.WOLF_DATA_MODEL or DataModel.PAUL_DATA_MODEL
%           outcome: Trial outcome to use: Valid values are  
%                    DataModel.WOLF_DATA_MODEL: 'Correct';
%                    DataModel.PAUL_DATA_MODEL: 'saccToTarget'
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
    minTrialsPerCondition = 7;

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
      
    % Specify conditions to for creating multiSdf
    %condition{x} = {alignOnEventName, TargetLeftOrRight, sdfWindow}
    conditions{1} = {'targetOnset', 'left', [-100 400]};
    conditions{2} = {'responseOnset', 'left', [-300 200]};
    conditions{3} = {'targetOnset', 'right', [-100 400]};
    conditions{4} = {'responseOnset', 'right', [-300 200]};

    distancesToCompute = {'correlation'};
    %nhpSessions = cell();

    parfor sessionIndex = 1:numel(sessionLocations)
        try
            sessionLocation = sessionLocations{sessionIndex};
            nhpInfo = nhpTable(sessionIndex,:);
            % Include probe number in session name
            if find(strcmp('probeNo',nhpInfo.Properties.VariableNames))
                sessionName = [nhpInfo.session{1} '_probe' num2str(nhpInfo.probeNo)];
            else
                sessionName = nhpInfo.session{1};
            end

            if isempty(sessionLocation)
                errorLogger.error(sprintf('Session %s has no datafiles. Using [ %s ] for spike file locations',...
                    sessionName, char(nhpInfo.matPath))); %#ok<PFBNS>
                continue
            end
                        
            multiSdf = struct();
            channelMap = nhpInfo.ephysChannelMap{1};
            logger.info(sprintf('Processing session %s',sessionName)); %#ok<PFBNS>
            if contains(lower(nhpInfo.chamberLoc),'left')
                ipsi = 'left';
            else
                ipsi = 'right';
            end
            % Create instance of MemoryTypeModel
            model = DataModel.newInstance(dataModelName, sessionLocation, channelMap);
            
            %check minTrialsPerCondition is satisfied
            checkMinTrialsPerCondition(model, outcome, conditions, minTrialsPerCondition);
            
            multiSdf.analysisDate = datestr(now);
            multiSdf.session = sessionName;
            multiSdf.info = nhpInfo;
            multiSdf.channelMap = model.getChannelMap;

            for c = 1:numel(conditions)
                currCondition = conditions{c};
                condStr = convertToChar(currCondition,ipsi);
                % make conditions explicit for understanding
                alignOn = currCondition{1};
                targetCondition = currCondition{2};
                sdfWindow = currCondition{3};
                logger.info(sprintf('Doing condition: outcome %s, alignOn %s, sdfWindow [%s]',...
                    targetCondition, alignOn, num2str(sdfWindow)));
                % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
                [~, multiSdf.(condStr)] = model.getMultiUnitSdf(model.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
                sdfPopulationZscoredMean = multiSdf.(condStr).sdfPopulationZscoredMean;
                for d = 1: numel(distancesToCompute)
                    distMeasureOption = distancesToCompute{d};
                    dMeasure = pdist2(sdfPopulationZscoredMean, sdfPopulationZscoredMean,distMeasureOption);
                    switch distMeasureOption
                        case 'correlation'
                            temp = (1-dMeasure).^2;
                            multiSdf.(condStr).rsquared = temp;
                        case {'euclidean', 'cosine'}
                            multiSdf.(condStr).rsquared = dMeasure;
                        otherwise
                    end
                end
            end
            oFile = fullfile(nhpOutputDir,[multiSdf.session '.mat']);
            logger.info(sprintf('Saving processed session to %s...',oFile));
            saveProcesssedSession(multiSdf, oFile);
            %nhpSessions=multiSdf;
            plotAndSaveFig(multiSdf, nhpOutputDir);
            
        catch me
            % log the error/exception causing failure and continue
            disp(me)
            logger.error(me);
            errorLogger.error(sprintf('Error processing session %s. Using [ %s ] for spike file locations',...
                sessionName, char(nhpInfo.matPath)));
            errorLogger.error(me);
        end
    end
end

%% Plot and save Figures
function [] = plotAndSaveFig(currSession, nhpOutputDir)
    plotsDir = [nhpOutputDir filesep 'figs'];
    if ~exist(plotsDir,'dir')
        mkdir(plotsDir)
        nixUpdateAttribs(plotsDir);        
    end
    try
        sessionLabel = currSession.session;
        doPlot8(currSession,sessionLabel, plotsDir);
    catch me
        % log the error/exception causing failure and continue
        logger.error(me);
        errorLogger.error(me);
    end
end

%% Save processed session
function saveProcesssedSession(currSession, oFile)   %#ok<INUSL>
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

function checkMinTrialsPerCondition(model, outcome, conditions, minTrials)
        tl = cell2mat(cellfun(@(x) numel(model.getTrialList(outcome,x{2})),conditions,'UniformOutput',false));
        if ~all(tl>minTrials)
            throw(MException('processSessions:checkMinTrialsPerCondition', 'MinTrialsPerCondition %d, failed!'));

        end
end
