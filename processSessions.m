function [ nhpSessions ] = processSessions(nhpConfig)
%PROCESSSESSIONS Summary of this function goes here
%   Detailed explanation goes here

%% TODOs
%  change:
%     'left_targOn'
%     'left_responseOnset'
%     'right_targOn'
%     'right_responseOnset'
%    ipis/contra based on the excel sheet
%     'ipsi_targOn_left'
%     'ipsi_responseOnset_left'
%     'contra_targOn_right'
%     'contra_responseOnset_right'


%%

    nhpConfig.nhp = 'joule';
    nhpConfig.srcNhpDataFolder = '/Volumes/schalllab/data/Joule';
    nhpConfig.excelFile = '/Users/subravcr/Projects/lab-schall/schalllab-clustering/matlab/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.nhpSheetName = 'Jo';
    nhpConfig.outputFolder = '/Users/subravcr/Projects/lab-schall/schalllab-clustering/clustering/schalllab-spatial/testData';
    
    nhp = nhpConfig.nhp;
    srcNhpDataFolder = nhpConfig.srcNhpDataFolder;
    excelFile = nhpConfig.excelFile;
    nhpSheetName = nhpConfig.nhpSheetName;
    outputFolder = nhpConfig.outputFolder;
    outputFile = fullfile(outputFolder,nhp,[nhp 'Spatial.mat']);
    
    % Read excel sheet
    nhpTable = readtable(excelFile, 'Sheet', nhpSheetName);


    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    %condition{x} = {alignOnEventName, TargetLeftOrRight, sdfWindow}
    conditions{1} = {'targOn', 'left', [-100 400]};
    conditions{2} = {'responseOnset', 'left', [-300 200]};
    conditions{3} = {'targOn', 'right', [-100 400]};
    conditions{4} = {'responseOnset', 'right', [-300 200]};

    distancesToCompute = {'correlation'};
    nhpSessions = struct();
    % fix filenames - remove single quotes
    sessions =  strcat(srcNhpDataFolder, filesep, regexprep(nhpTable.filename,'''',''));
    for s = 1: 1 %size(nhpTable,1)
        nhpInfo = nhpTable(s,:);
        sessionLocation = sessions{s};
        if contains(lower(nhpInfo.chamberLoc),'left')
            ipsi = 'left';
        else
            ipsi = 'right';
        end
        fprintf('Processing file %s\n',sessionLocation);
        [~,session,~] = fileparts(sessionLocation);

        % Create instance of MemoryTypeModel
        jouleModel = EphysModel.newEphysModel('memory',sessionLocation);

        zscoreMinMax = nan(numel(conditions),2);
        distMinMax = struct();
        for c = 1:numel(conditions)
            currCondition = conditions{c};
            condStr = convertToChar(currCondition,ipsi);
            % make conditions explicit for understanding
            alignOn = currCondition{1};
            targetCondition = currCondition{2};
            sdfWindow = currCondition{3};
            fprintf('Doing condition: outcome %s, alignOn %s, sdfWindow [%s]\n',...
                targetCondition, alignOn, num2str(sdfWindow));
            % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
            [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
            sdfPopulationZscoredMean = multiSdf.(condStr).sdfPopulationZscoredMean;
            zscoreMinMax(c,:) = minmax(sdfPopulationZscoredMean(:)');
            for d = 1: numel(distancesToCompute)
                distMeasureOption = distancesToCompute{d};
                dMeasure = pdist2(sdfPopulationZscoredMean, sdfPopulationZscoredMean,distMeasureOption);
                switch distMeasureOption
                    case 'correlation'
                        temp = (1-dMeasure).^2;
                        multiSdf.(condStr).rsquared = temp;
                        distMinMax.(distMeasureOption)(c,:) = minmax(temp(:)');
                    case {'euclidean', 'cosine'}
                        multiSdf.(condStr).rsquared = dMeasure;
                        distMinMax.(distMeasureOption )(c,:) = minmax(dMeasure(:)');
                    otherwise
                end
            end
        end
        nhpSessions.(session) = multiSdf;
        nhpSessions.(session).info = nhpInfo;
    end
    save(outputFile, '-struct', 'nhpSessions');
    
    %% Plot and save Figures
    sessionLabels = fieldnames(nhpSessions);
%     conditionLabels = fieldnames(nhpSessions.(sessionLabels{1}));
%     conditionLabels = ~contains(conditionLabels,'info'); %columns for plot
    for s = 1:numel(sessionLabels)
        sessionLabel = sessionLabels{s};
        doPlot8(nhpSessions.(sessionLabel),sessionLabel);
            
%         for c = 1 : numel(conditionLabels) % plot by columns
%             conditionLabel = conditionLabels{c};
%             session = nhpSessions.()
%         end
        
    end
    
    
end

function [ condStr ] = convertToChar(condCellArray, ipsiSide)
    indexChars = cellfun(@(x) ischar(x),condCellArray);
    charStr = char(join(condCellArray(indexChars),'_'));
    if contains(charStr,ipsiSide)
        condStr = ['ipsi_' charStr];
    else
        condStr = ['contra_' charStr];
    end
end


%function [ figH ] = doPlot8(multiSdf, sdfDist, plotHeatmapFor, currMeasure, plotColumnOrder, channelMap, filename)
function [ figH ] = doPlot8(session, sessionLabel)
        
    leftRight = {'left' 'right'};
    ipsi = contains(leftRight, lower(session.info.hemi));
    contra = ~contains(leftRight, lower(session.info.hemi));

    conditions = fieldnames(session);
    conditions = conditions(~contains(conditions,'info')); %columns for plot

    targetPosAlignOn=cell2table(cellstr(split(conditions,'_')),'VariableNames',{'targetPos','alignOn'});
    ic = targetPosAlignOn.targetPos;
    ic = regexprep(ic,leftRight{ipsi},'ipsi');
    ic = regexprep(ic,leftRight{contra},'contra');
    targetPosAlignOn.ipsiContra = ic;
    targetPosAlignOn.conditions = conditions;
    % row order is the plot order
    targetPosAlignOn = sortrows(targetPosAlignOn,'alignOn','descend');

    firingRateHeatmap = 'sdfPopulationZscoredMean';
    distMeasure = 'rsquared';

    frPlots = cell(4,1);
    distPlots = cell(4,1);
    % get SDFs / zscores to plot there will be 4 of these
    % create in column order
    for p = 1:size(targetPosAlignOn)
        frPlots{p} = session.(targetPosAlignOn.conditions{p}).(firingRateHeatmap);
        distPlots{p} = session.(targetPosAlignOn.conditions{p}).(distMeasure);
    end    
    
    temp = cell2mat(frPlots);
    frMinMax = minmax(temp(:)');
    temp = cell2mat(distPlots);
    distMinMax = minmax(temp(:)');

    %plot by columns
    plotHandles = plot8axes;
    figH = get(plotHandles(1),'Parent');

    channelMap = 1 : size(frPlots{1},1);
    channelTicks = 2:2:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(x)],channelTicks,'UniformOutput',false);
    plotIndicesByRowHandles = [1:2:8;2:2:8];
    for co = 1:4
        currPlotsIndex = plotIndicesByRowHandles(:,co);
        colCond = targetPosAlignOn.conditions{co};
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
                    titleYpos1 = min(ylim) - range(ylim)/12;
                    titleYpos2 = min(ylim) - 1.5*(range(ylim)/12);
                    text(titleXpos,titleYpos1,upper(targetPosAlignOn.conditions(co)),...
                        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color','b',...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap',...
                        'Interpreter','none');
                     text(titleXpos,titleYpos2,upper(targetPosAlignOn.ipsiContra(co)),...
                        'FontWeight','bold','FontAngle','italic','FontSize',16,'Color','m',...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap',...
                        'Interpreter','none');
                    if co == 1
                        ylabel([firingRateHeatmap ' heatmap'],'VerticalAlignment','bottom');
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
                        ylabel([distMeasure ' (r^2)'],'VerticalAlignment','bottom');
                    end
            end
            drawnow
            %addFigureTitle(sessionLabel);
            %addDateStr()
    
            figureTitle = sessionLabel;
    ht = axes('Units','Normal','Position',[.02 .90 .94 .06],'Visible','on');
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold')
    
    
    hd = axes('Units','Normal','Position',[.9 .02 .06 .04],'Visible','off');
    text(0.1,0.1,datestr(now))

        end
    end
end

function addFigureTitle(figureTitle)
    h = axes('Units','Normal','Position',[.02 .02 .94 .94],'Visible','off');
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold')
end

function addDateStr()
    h = axes('Units','Normal','Position',[.9 .02 .06 .04],'Visible','off');
    text(0.1,0.1,datestr(now))
end
