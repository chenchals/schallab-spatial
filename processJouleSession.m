function [ multiSdf, sdfDist ] = processJouleSession(jouleFile)

    %jouleFile ='/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp125n01.mat';
    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    conditions{1} = {'left', 'targOn', [-100 400]};
    conditions{2} = {'left', 'responseOnset', [-300 200]};
    conditions{3} = {'right', 'targOn', [-100 400]};
    conditions{4} = {'right', 'responseOnset', [-300 200]};
    
    distToCompute = {'correlation'};
    
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
        for d = 1: numel(distToCompute) 
          distMeasure = distToCompute{d};
          switch distMeasure
              case 'correlation'
                  temp = (1-pdist2(sdf_population_zscored_mean, sdf_population_zscored_mean,distMeasure)).^2;
                  sdfDist.sdf_population_zscored_mean.([distMeasure '_squared']).(condStr) = temp;
                  distMinMax.([distMeasure '_squared'])(c,:) = minmax(temp(:)'); 
              otherwise
          end
        end
    end
        
    % plots
%     figH = figure('Units','normalized', 'Position', [0.05 0.05 0.9 0.9]);
%     set(0, 'currentfigure', figH);
    zColorbarLim = minmax(zscoreMinMax(:)');
    distCorrColorbarLim =minmax(distMinMax.correlation_squared(:)');
    
    plotHandles = plot8axes;
    figH = get(plotHandles(1),'Parent');
    columnConditions={
        'left_targOn'
        'right_targOn'
        'left_responseOnset'
        'right_responseOnset'
        };
    rowConditions = {
        'sdf_population_zscored_mean'
        'sdf_population_zscored_mean.correlation_squared'
        };
    % The figure is 2 rows by 4 columns
    % col 1 = left_targOn col 2 = right_targOn
    channelTicks = 4:4:numel(channelMap);
    plotRows = 2;
    plotCols = 4;
    channelTickLabels = arrayfun(@(x) ['#' num2str(x)],channelTicks,'UniformOutput',false);
    for col = 1:plotCols
        currPlots = plotHandles((col-1)*plotRows+1:col*plotRows);
        colCond = columnConditions{col};
        for ro = 1:plotRows
            rowCond = rowConditions{ro};
            currplotHandle = currPlots(ro);
            set(figH, 'currentaxes', currplotHandle);
            currAxes = gca;
            switch ro
                case 1 %Firing Rate heatmap
                    imagesc(multiSdf.(colCond).(rowCond)); 
                    h = colorbar;
                    set(h,'YLim', zColorbarLim);
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
                    
                    if col == 1
                        ylabel('Mean z-scored firing rate heatmap','VerticalAlignment','bottom');
                    end
                                       
                case 2 % distance matrix for sdf_mean
                    imagesc(eval(['sdfDist.' rowCond '.' colCond ';']));
                    h = colorbar;
                    set(h,'YLim', distCorrColorbarLim);
                    currAxes.XTick = channelTicks;
                    currAxes.XTickLabelRotation = 90;
                    currAxes.XTickLabel = channelTickLabels;
                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;
                    
                    if col == 1
                        ylabel('Similarity (r^2)','VerticalAlignment','bottom');
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