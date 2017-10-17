function [ figH ] = doPlot8(session, sessionLabel, varargin)
%DOPLOT8 Summary of this function goes here
%   Detailed explanation goes here

%% Do a 8 part figure plot
    fprintf('Plotting session %s\n',sessionLabel);
    figVisible = 'on';

    if numel(varargin)==1
        outputFolder = varargin{1};
        saveFig = true;
    else
        saveFig = false;
    end
    
    firingRateHeatmap = 'sdfPopulationZscoredMean';
    distMeasure = 'rsquared';

    ipsiContraOrder = {'ipsi','contra'};
    alignOnOrder = {'targetOnset', 'responseOnset'};

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
    set(figH,'Visible',figVisible);

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
                    ro1Plot(isnan(ro1Plot)) = frMinMax(2);
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
                    ro2Plot(isnan(ro2Plot)) = distMinMax(2);
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
    addFigureTitleAndInfo(sessionLabel, session, infosHandle);
    addDateStr();
    drawnow
    if saveFig
        oFile = fullfile(outputFolder,sessionLabel);
        fprintf('Saving figure to file %s\n',oFile);
        saveas(figH,oFile,'jpg');
        saveas(figH,oFile, 'fig');
        nixUpdateAttribs([oFile '*.*']);
    end
    
    if strcmp(figVisible, 'off')
        delete(figH)
    end
    
end
%% Add figure title and Info
function addFigureTitleAndInfo(figureTitle, session, varargin)
    if numel(varargin)==0 || isempty(varargin{1})
        h = axes('Units','normalized','Position',[.01 .87 .98 .09]);
    else
        h = varargin{1};
    end
    set(get(h,'Title'),'Visible','on');
    title(figureTitle,'fontSize',20,'fontWeight','bold','Interpreter','none');
    h.XTick = [];
    h.YTick = [];
    h.Visible = 'on';
    h.Box = 'on';
    infoTable = session.info;
    varNames=infoTable.Properties.VariableNames;
    % remove channelMap from varnames
    varNames = varNames(~contains(varNames,'ephysChannelMap'));
    propsPerCol = 5;
    fontSize = 12;
    columnGap = 0.02;
    nCols = ceil(numel(varNames)/propsPerCol)+1;
    xPos=0.01;
    yPos = 0.9;
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
            t{i} = [name,' : ',value];
        end
        hText = text(xPos,yPos,t,'Interpreter','none',...
            'FontWeight','bold','FontSize',fontSize,...
            'VerticalAlignment', 'top','HorizontalAlignment','left');
        xPos = getNextXPos(hText, columnGap);
    end
    chanMap = infoTable.ephysChannelMap{:};
    chanRows = 4;
    chanCols = ceil(numel(chanMap)/chanRows);
    hText = text(xPos,yPos,{'ePhysChannelMap'; ...
        num2str(reshape(chanMap,chanCols,chanRows)','%02d, ')},...
        'Interpreter','none','FontWeight','bold','FontSize',fontSize,...
        'VerticalAlignment', 'top','HorizontalAlignment','left');
     xPos = getNextXPos(hText, columnGap);
            % write Analysis date
    text(xPos,yPos,['Analysis Date : ' session.analysisDate],...
        'Interpreter','none','FontWeight','bold','FontSize',fontSize,...
        'VerticalAlignment', 'top','HorizontalAlignment','left');
end

%% Get next X position fron the previous plot extens
function [ xPos ] = getNextXPos(hText, columnGap)
        xPos = get(hText,'Extent');
        xPos = xPos(1) + xPos(3) + columnGap;
end

%% Add Plot date time
function addDateStr()
    axes('Units','normalized','Position',[0.90 .02 .06 .04],'Visible','off');
    text(0.1,0.1,['Plotted Date : ' datestr(now)],'FontSize',11,'HorizontalAlignment','right');
end

% Not used
function [ tableHeader ] = getTableHeader() %#ok<DEFNU>
tableHeader = {
    'nhp'
    'notebook'
    'pages'
    'date'
    'rig'
    'scientist'
    'paradigm'
    'session'
 %   'matPath'
    'probeNo'
 %   'rawPath'
 %   'filename_behavior'
    'probe'
    'area'
    'chamberLoc'
    'ipsi'
    'contra'
    'ap'
    'ml'
    'ap_mm'
    'ml_mm'
    'cotexSurface_um'
    'settle_um'
    'depth_um'
    'channelSpacing'
    'ephysChannelMap'
    'channelClosestToSurface'
    'grid_reference'
    };
end



