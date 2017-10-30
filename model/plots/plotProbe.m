function [ ] = plotProbe(probeLoc, channelSpacing, channelMap, beginEndCluster, reverseYdir, varargin)
%PLOTPROBE Summary of this function goes here
%   Detailed explanation goes here

    currAxes = gca;
    figH = get(currAxes,'Parent');
 
    if reverseYdir
        set(currAxes,'YDir','reverse');
    end
    faceColors= {'r','b','g','c','m','y'};
    if numel(varargin)==1
       faceColors= {'r','r','r','r','r','r'};
    end

    if isnan(channelSpacing)
        channelSpacing = 200;
    end

    % Plot probe outline
    %probeAxes = plotProbeOutline(currAxes);

    % change currAxes
    set(figH,'currentAxes', currAxes);
    
    % Plot channels
    maxChannels = numel(channelMap);
    xData = zeros(maxChannels,1)+probeLoc;
    yData = (0:maxChannels-1)+0.5;
    [plAxis,hLine1,hLine2] = plotyy(xData,yData,xData,yData); %
    
    set([hLine1,hLine2],'LineStyle','none','Marker','o','MarkerEdgeColor','k')
    
    channelTicks = 1.5:2:maxChannels;% offset by 0.5
    channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks+0.5,'UniformOutput',false);
    depthTickLabels = arrayfun(@(x) [num2str(x) ' \mum'],(channelTicks+0.5).*channelSpacing,'UniformOutput',false);
     xstep = 0.1; 
    set(plAxis(1),'YTick',channelTicks,'YTickLabel',channelTickLabels,'YColor','k');    
    set(plAxis(2),'YTick',channelTicks,'YTickLabel',depthTickLabels,'YColor','k');
    set(plAxis,'YDir','reverse','XTick',[],'TickDir','both','box','on');
    set(plAxis,'YLim',[0 maxChannels],'XLim',[probeLoc-xstep probeLoc+xstep]);
    %hold on
    set(figH,'currentAxes', plAxis(1));
    %plot clusters
    xData = [probeLoc-xstep probeLoc+xstep probeLoc+xstep probeLoc-xstep]; %centered at 1
    y1 = beginEndCluster(:,1);
    y2 = (beginEndCluster(:,2)+1);
    
    for clust = 1:numel(y1)
        yData = [y1(clust) y1(clust) y2(clust) y2(clust)];
        patch('XData', xData, 'YData', yData, 'FaceColor', faceColors{clust},'FaceAlpha',0.9);
        hold on
    end
    % draw probe outline
    xData = [probeLoc-xstep probeLoc+xstep probeLoc+xstep probeLoc probeLoc-xstep];
    %yData = [maxChannels+3 maxChannels+3 -1 -3 -1];

    yData = [-3 -3 maxChannels+1 maxChannels+3 maxChannels+1];
    patch('XData',xData,'YData',yData','FaceColor',[0.8,0.8,0.8],'FaceAlpha',0.4);
    currAxes.Clipping ='off';   
    
end

