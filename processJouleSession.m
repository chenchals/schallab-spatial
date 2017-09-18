function [ multiSdf, sdfDist ] = processJouleSession(jouleFile)
    % dj=dir('/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/*.mat');
    % jouleFiles = strcat({dj.folder}', filesep, {dj.name}');
    %jouleFile ='/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp125n01.mat';
    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    conditions{1} = {'left', 'targOn', [-100 400]};
    conditions{2} = {'left', 'responseOnset', [-300 200]};
    conditions{3} = {'right', 'targOn', [-100 400]};
    conditions{4} = {'right', 'responseOnset', [-300 200]};

    distancesToCompute = {'correlation', 'euclidean', 'cosine'};

    fullFileName = jouleFile;
    fprintf('Processing file %s\n',fullFileName);
    [~,filename,~] = fileparts(fullFileName);

    % Create instance of MemoryTypeModel
    jouleModel = EphysModel.newEphysModel('memory',fullFileName);
    channelMap = jouleModel.getChannelMap();
    zscoreMinMax = nan(numel(conditions),2);
    distMinMax = struct();
    for c = 1:numel(conditions)
        currCondition = conditions{c};
        condStr = convertToChar(currCondition);
        % make conditions explicit for understanding
        targetCondition = currCondition{1};
        alignOn = currCondition{2};
        sdfWindow = currCondition{3};
        fprintf('Doing conndition: outcome %s, alignOn %s, sdfWindow [%s]\n',...
            targetCondition, alignOn, num2str(sdfWindow));
        % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
        [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
        sdf_population_zscored_mean = multiSdf.(condStr).sdf_population_zscored_mean;
        zscoreMinMax(c,:) = minmax(sdf_population_zscored_mean(:)');
        for d = 1: numel(distancesToCompute)
            distMeasure = distancesToCompute{d};
            dMeasure = pdist2(sdf_population_zscored_mean, sdf_population_zscored_mean,distMeasure);
            switch distMeasure
                case 'correlation'
                    temp = (1-dMeasure).^2;
                    sdfDist.sdf_population_zscored_mean.(distMeasure).(condStr) = temp;
                    distMinMax.(distMeasure)(c,:) = minmax(temp(:)');
                case {'euclidean', 'cosine'}
                    sdfDist.sdf_population_zscored_mean.(distMeasure).(condStr) = dMeasure;
                    distMinMax.(distMeasure )(c,:) = minmax(dMeasure(:)');
                otherwise
            end
        end
    end

    % Create 1 plot8 for each distance measure
    plotColumnOrder={
        'left_targOn'
        'right_targOn'
        'left_responseOnset'
        'right_responseOnset'
        };
    plotHeatmapFor = 'sdf_population_zscored_mean';
    for dMeasure = 1:numel(distancesToCompute)
        currMeasure = distancesToCompute{dMeasure};
        doPlot8(multiSdf, sdfDist, plotHeatmapFor, currMeasure, plotColumnOrder, channelMap, filename );
    end
end

function [ figH ] = doPlot8(multiSdf, sdfDist, plotHeatmapFor, currMeasure, plotColumnOrder, channelMap, filename)
    plotHandles = plot8axes;
    figH = get(plotHandles(1),'Parent');
    columnConditions = plotColumnOrder;
    firingRateHeatmap = plotHeatmapFor;
    distMeasure = currMeasure;

    frPlots = cell(4,1);
    distPlots = cell(4,1);
    % get SDFs / zscores to plot there will be 4 of these
    for co = 1:numel(columnConditions)
        frPlots{co} = multiSdf.(columnConditions{co}).(firingRateHeatmap);
        distPlots{co} = sdfDist.(firingRateHeatmap).(distMeasure).(columnConditions{co});
    end
    temp = cell2mat(frPlots);
    frMinMax = minmax(temp(:)');
    temp = cell2mat(distPlots);
    distMinMax = minmax(temp(:)');

    %plot by columns
    channelTicks = 4:4:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(x)],channelTicks,'UniformOutput',false);
    plotIndicesByRowHandles = [1:2:8;2:2:8];
    for co = 1:4
        currPlotsIndex = plotIndicesByRowHandles(:,co);
        colCond = columnConditions{co};
        for ro = 1:2
            ro1Plot = frPlots{co};
            ro2Plot = distPlots{co};
            currplotHandle = plotHandles(currPlotsIndex(ro));
            set(figH, 'currentaxes', currplotHandle);
            currAxes = gca;
            switch ro
                case 1 %Firing Rate heatmap
                    imagesc(ro1Plot);
                    h = colorbar;
                    set(h,'YLim', frMinMax);
                    timeWin = multiSdf.(colCond).sdfWindow;
                    step = range(timeWin)/5;
                    currAxes.XTick = 0:step:range(timeWin);
                    currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):step:max(timeWin),'UniformOutput',false);

                    align0 = find(min(timeWin):max(timeWin)==0);
                    line([align0 align0], ylim, 'Color','r');

                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;

                    titleText = colCond;
                    titleXpos = range(timeWin)/2;
                    titleYpos = min(ylim) - range(ylim)/10;
                    text(titleXpos,titleYpos,upper(titleText),...
                        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color','b',...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap',...
                        'Interpreter','none');

                    if co == 1
                        ylabel([firingRateHeatmap ' heatmap'],'VerticalAlignment','bottom');
                    end

                case 2 % distance matrix for sdf_mean
                    imagesc(ro2Plot);
                    h = colorbar;
                    set(h,'YLim', distMinMax);
                    currAxes.XTick = channelTicks;
                    currAxes.XTickLabelRotation = 90;
                    currAxes.XTickLabel = channelTickLabels;
                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;

                    if co == 1
                        label = currMeasure;
                        if regexp(label,'correlation','once')
                            label = [label '(r^2)'];
                        end

                        ylabel(label,'VerticalAlignment','bottom');
                    end
            end
            drawnow
            addFigureTitle(filename);
        end
    end
end


function [ condStr ] = convertToChar(condCellArray)
    indexChars = cellfun(@(x) ischar(x),condCellArray);
    charStr = char(join(condCellArray(indexChars),'_'));
    condStr = charStr;
end

function addFigureTitle(figureTitle)
    h = axes('Units','Normal','Position',[.02 .02 .94 .94],'Visible','off');
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold')
end