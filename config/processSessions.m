function [ nhpSessions ] = processSessions(nhpConfig)
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
% See also PROCESSJOULE

    nhp = nhpConfig.nhp;
    nhpSourceDir = nhpConfig.nhpSourceDir;
    excelFile = nhpConfig.excelFile;
    sheetName = nhpConfig.sheetName;
    nhpOutputDir = nhpConfig.nhpOutputDir;
    getSessions = nhpConfig.getSessions;

    if ~exist(nhpOutputDir,'dir')
        mkdir(nhpOutputDir);
    end
    outputFile = fullfile(nhpOutputDir,[nhp 'Spatial.mat']);
    logger = Logger.getLogger(fullfile(nhpOutputDir,[nhp 'ProcessSessions.log']));
    errorLogger = Logger.getLogger(fullfile(nhpOutputDir,[nhp 'ProcessSessionsErrors.log']));
    
    save(outputFile, 'nhpConfig');
    % Read excel sheet
    nhpTable = readtable(excelFile, 'Sheet', sheetName);
    nhpTable.date = datestr(nhpTable.date,'mm/dd/yyyy');
    nhpTable.ephysChannelMap = arrayfun(@(x) ...
        str2num(char(split(nhpTable.ephysChannelMap{x},', '))),...
        1:size(nhpTable,1),'UniformOutput',false)';   %#ok<ST2NM>

    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    %condition{x} = {alignOnEventName, TargetLeftOrRight, sdfWindow}
    conditions{1} = {'targOn', 'left', [-100 400]};
    conditions{2} = {'responseOnset', 'left', [-300 200]};
    conditions{3} = {'targOn', 'right', [-100 400]};
    conditions{4} = {'responseOnset', 'right', [-300 200]};

    distancesToCompute = {'correlation'};
    sessions = getSessions(nhpSourceDir, nhpTable);
    nhpSessions = cell(numel(sessions),1);
    %parfor s = 1:numel(sessions)
    for s = 1:numel(sessions)
        try
            multiSdf = struct();
            nhpInfo = nhpTable(s,:);
            sessionLocation = sessions{s};
            channelMap = nhpInfo.ephysChannelMap{1};
            logger.info(sprintf('Processing file %s',sessionLocation));
            [~,session,~] = fileparts(sessionLocation);

            if contains(lower(nhpInfo.chamberLoc),'left')
                ipsi = 'left';
            else
                ipsi = 'right';
            end

            % Create instance of MemoryTypeModel
            jouleModel = EphysModel.newEphysModel('memory',sessionLocation, channelMap);

            multiSdf.analysisDate = datestr(now);
            multiSdf.session = session;
            multiSdf.info = nhpInfo;
            multiSdf.channelMap = jouleModel.getChannelMap;

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
                [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
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
            nhpSessions{s}=multiSdf;
        catch me
            % log the error/exception causing failure and continue
            disp(me)
            logger.error(me);
            errorLogger.error(me);
        end
    end
    %Since there may be processing errors for one or more sessions
    nhpSessions = nhpSessions(~cellfun(@isempty,nhpSessions));

    % since we are using parfor to compute, reconvert from struct array
    % back to struct with session as fieldname
    finalVar = struct;
    for ii = 1:numel(nhpSessions)
        finalVar.(nhpSessions{ii}.session)=nhpSessions{ii};
    end
    nhpSessions = finalVar;
    clearvars 'finalVar';

    % save fieldnames (session) as individual vars in file
    logger.info(sprintf('Saving processed output to %s...',outputFile));
    save(outputFile, '-struct', 'nhpSessions');
    %fprintf('done');

    %% Plot and save Figures
    sessionLabels = fieldnames(nhpSessions);
    for s = 1:numel(sessionLabels)
        try
            sessionLabel = sessionLabels{s};
            figH = doPlot8(nhpSessions.(sessionLabel),sessionLabel);
            saveas(figH,fullfile(nhpOutputDir,sessionLabel),'jpg');
            saveas(figH,fullfile(nhpOutputDir,sessionLabel), 'fig');
        catch me
            % log the error/exception causing failure and continue
            logger.error(me);
            errorLogger.error(me);
        end
    end
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

%% Do a 8 part figure plot - move to plots folder?
function [ figH ] = doPlot8(session, sessionLabel)

    firingRateHeatmap = 'sdfPopulationZscoredMean';
    distMeasure = 'rsquared';

    ipsiContraOrder = {'ipsi','contra'};
    alignOnOrder = {'targOn', 'responseOnset'};

    conditions = fieldnames(session);
    frPlots = cell(4,1);
    distPlots = cell(4,1);
    titlePlots = cell(4,1);
    % get SDFs / zscores to plot there will be 4 of these
    % create in column order
    plotNo = 0;
    for align = 1:numel(alignOnOrder)
        for ic = 1:numel(ipsiContraOrder)
            charIc = ipsiContraOrder{ic};
            CharAlignOn = alignOnOrder{align};
            plotNo = plotNo+1;
            fieldnameIndex = contains(conditions, join({charIc,CharAlignOn},'_'));
            frPlots{plotNo} = session.(conditions{fieldnameIndex}).(firingRateHeatmap);
            distPlots{plotNo} = session.(conditions{fieldnameIndex}).(distMeasure);
            titlePlots{plotNo} = conditions{fieldnameIndex};
        end
    end

    temp = cell2mat(frPlots);
    frMinMax = minmax(temp(:)');
    temp = cell2mat(distPlots);
    distMinMax = minmax(temp(:)');

    %plot by columns
    infosHandle = [];
    plotHandles = plot8axes;
    %[plotHandles, infosHandle] = plot8part;
    figH = get(plotHandles(1),'Parent');

    channelTicks = 2:2:numel(session.channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(session.channelMap(x))],channelTicks,'UniformOutput',false);
    plotIndicesByRowHandles = [1:2:8;2:2:8];
    for co = 1:4
        currPlotsIndex = plotIndicesByRowHandles(:,co);
        colCond = titlePlots{co};
        for ro = 1:2
            ro1Plot = frPlots{co};
            ro2Plot = distPlots{co};
            currplotHandle = plotHandles(currPlotsIndex(ro));
            set(figH, 'currentaxes', currplotHandle);
            currAxes = gca;
            switch ro
                case 1 %Firing Rate heatmap
                    imagesc(ro1Plot,frMinMax);
                    h = colorbar;
                    set(h,'YLim', frMinMax);
                    timeWin = session.(colCond).sdfWindow;
                    step = range(timeWin)/5;
                    currAxes.XTick = 0:step:range(timeWin);
                    currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):step:max(timeWin),'UniformOutput',false);

                    align0 = find(min(timeWin):max(timeWin)==0);
                    line([align0 align0], ylim, 'Color','r');

                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;

                    titleXpos = range(timeWin)/2;
                    titleYpos = min(ylim) - range(ylim)/12;
                    text(titleXpos,titleYpos,upper(colCond),...
                        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color','b',...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap',...
                        'Interpreter','none');
                    if co == 1
                        ylabel([firingRateHeatmap ' heatmap'],'VerticalAlignment','bottom','FontWeight','bold');
                    end

                case 2 % distance matrix for sdf_mean
                    imagesc(ro2Plot,distMinMax);
                    h = colorbar;
                    set(h,'YLim', distMinMax);
                    currAxes.XTick = channelTicks;
                    currAxes.XTickLabelRotation = 90;
                    currAxes.XTickLabel = channelTickLabels;
                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;

                    if co == 1
                        ylabel([distMeasure ' (r^2)'],'VerticalAlignment','bottom','FontWeight','bold');
                    end
            end
        end
    end
    addFigureTitleAndInfo(sessionLabel, session.info, infosHandle);
    addDateStr();
    drawnow
end
%% Add figure title and Info
function addFigureTitleAndInfo(figureTitle, infoTable, varargin)
    if numel(varargin)==0 || isempty(varargin{1})
        h = axes('Units','normalized','Position',[.01 .87 .98 .09]);
    else
        h = varargin{1};
    end
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold');
    h.XTick = [];
    h.YTick = [];
    h.Visible = 'on';
    h.Box = 'on';
    varNames=infoTable.Properties.VariableNames;
    % remove channelMap from varnames
    varNames = varNames(~contains(varNames,'ephysChannelMap'));
    propsPerCol = 4;
    nCols = ceil(numel(varNames)/propsPerCol)+1;
    xPos=(0:1.0/nCols:1.0)+0.01;
    xPos = xPos(1:end-1);
    for c = 1:nCols-1 % last col channelMap
        t = cell(propsPerCol,1);
        ind = (c-1)*propsPerCol+1:c*propsPerCol;
        ind = ind(ind<=numel(varNames));
        for i = 1:numel(ind)
            name = varNames{ind(i)};
            value = infoTable.(name);
            if isnumeric(value)
                value = num2str(value);
            else
                value = char(value);
            end
            t{i} = strcat(name,':',value);
        end
        text(xPos(c),0.5,t,'Interpreter','none','FontWeight','bold','FontSize',10);
    end
    chanMap = infoTable.ephysChannelMap{:};
    chanRows = 4;
    chanCols = ceil(numel(chanMap)/chanRows);
    text(xPos(end),0.5,{'ePhysChannelMap'; ...
        num2str(reshape(chanMap,chanCols,chanRows)','%02d, ')},...
        'Interpreter','none','FontWeight','bold','FontSize',10)
end
%% Add Plot date time 
function addDateStr()
    axes('Units','normalized','Position',[.9 .02 .06 .04],'Visible','off');
    text(0.1,0.1,datestr(now))
end
