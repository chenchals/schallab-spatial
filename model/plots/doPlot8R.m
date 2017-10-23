function [ figH ] = doPlot8R(session, sessionLabel, colorbarNames, varargin)
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
    
    firingRateHeatmap = 'sdfMeanZtr';
    distMeasure = 'rsquared';

    row1Conditions = {'contra_targetOnset', 'contra_responseOnset'};
    row2Conditions = {'ipsi_targetOnset', 'ipsi_responseOnset'};

    conditions = fieldnames(session);
    % contra: {{frTarg,distTarg};{frResp,distResp}}
    row1Plots = arrayfun(@(x) {...
        session.(conditions{x}).(firingRateHeatmap)...
        session.(conditions{x}).(distMeasure)},...
        find(contains(conditions,row1Conditions)),'UniformOutput',false);
    % ipsi: {{frTarg,distTarg};{frResp,distResp}}
    row2Plots = arrayfun(@(x) {...
        session.(conditions{x}).(firingRateHeatmap)...
        session.(conditions{x}).(distMeasure)},...
        find(contains(conditions,row2Conditions)),'UniformOutput',false);
    rowPlotTitles = {
        conditions{contains(conditions,row1Conditions)}
        conditions{contains(conditions,row2Conditions)}
        };

    temp = cell2mat(cellfun(@(x) x{1},[row1Plots;row2Plots],'UniformOutput',false));
    frMinMax = minmax(temp(:)');
    temp = cell2mat(cellfun(@(x) x{2},[row1Plots;row2Plots],'UniformOutput',false));
    distMinMax = minmax(temp(:)');

    %plot by columns
    infosHandle = [];
    plotHandles = plot8axes;
    %[plotHandles, infosHandle] = plot8part;
    figH = get(plotHandles(1),'Parent');
    set(figH,'Visible',figVisible);

    channelTicks = 2:2:numel(session.channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(session.channelMap(x))],channelTicks,'UniformOutput',false);
    plotIndicesByRows = {
        {[1 3] [5 7]}
        {[2 4] [6 8]}
        };
    plots = {row1Plots;row2Plots};
    titleColors = {'r','b'};
    for ros = 1:2
        rowPlots = plots{ros};
        rowTitles = rowPlotTitles(ros,:)';
        roPlotIndices = plotIndicesByRows{ros};
        for titleIndex = 1:numel(rowTitles)
            plotIndices = roPlotIndices{titleIndex};
            currPlots = rowPlots{titleIndex};
            cond = rowTitles{titleIndex};
            for co = 1:2
                currplotHandle = plotHandles(plotIndices(co));
                set(figH, 'currentaxes', currplotHandle);
                currAxes = gca;
                switch co
                    case 1 %Firing Rate heatmap
                        imagescWithNan(currPlots{1},frMinMax,[],1,colorbarNames{1});
                        timeWin = session.(cond).sdfWindow;
                        step = range(timeWin)/5;
                        currAxes.XTick = 0:step:range(timeWin);
                        currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):step:max(timeWin),'UniformOutput',false);
                        
                        align0 = find(min(timeWin):max(timeWin)==0);
                        line([align0 align0], ylim, 'Color','r');
                        
                        currAxes.YTick = channelTicks;
                        currAxes.YTickLabel = channelTickLabels;
                        
                        pos = get(title(''),'Position');
                        text(pos(1),pos(2),{upper(cond), upper([firingRateHeatmap ' heatmap'])},...
                            'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColors{ros},...
                            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
                            'Interpreter','none');
                        
                        ylabel('Channel#','FontWeight','bold', 'FontSize',12);
                        xlabel('time (ms)','FontWeight','bold', 'FontSize',12);
                        
                    case 2
                        imagescWithCluster(currPlots{2},distMinMax,0.5,1,colorbarNames{2});
                        currAxes.XTick = channelTicks;
                        currAxes.XTickLabelRotation = 90;
                        currAxes.XTickLabel = channelTickLabels;
                        currAxes.YTick = channelTicks;
                        currAxes.YTickLabel = channelTickLabels;
                        
                        pos = get(title(''),'Position');
                        text(pos(1),pos(2),{upper(cond), upper([distMeasure ' (r^2)'])},...
                            'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColors{ros},...
                            'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
                            'Interpreter','none');
                        
                        ylabel('Channel#','FontWeight','bold', 'FontSize',12);
                        xlabel('Channel#','FontWeight','bold', 'FontSize',12);
                        
                end
            end %co
            
        end %titleIndex
        
    end %ros
 
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
    axes('Units','normalized','Position',[0.96 .01 .03 .02],'Visible','off');
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



