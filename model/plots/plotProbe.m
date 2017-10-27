function [ ] = plotProbe(probeLoc, channelSpacing, channelMap, beginEndCluster, reverseYdir, varargin)
%PLOTPROBE Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
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
    % vertices = [lowerLeft, lowerRight, upperRight, upperLeft]
    % vertices = [x1y1, x2y1, x2y2, x1y2]
    %x = x1,x2,x1,x2
    xstep = 0.2;
    % probe outline
    maxChannels = numel(channelMap);
    xData = [probeLoc-xstep probeLoc-xstep probeLoc probeLoc+xstep probeLoc+xstep];
    xLim = minmax(xData);
    yData = [4900 -200 -800 -200 4900];
    if reverseYdir % the point should face dowm, which is higher Y
        %yData =[-800 5000 5500 5000 -800];
        yData =[-800 5000 5500 5000 -800];
    end
    yLim = minmax(yData);

    patch('XData',xData,'YData',yData,'FaceColor',[0.9 0.9 0.9],'LineWidth', 0.1)
    hold on
    plot(zeros(maxChannels,1)+probeLoc,(1:maxChannels).*channelSpacing,'ok') %

    %plot clusters
    xData = [probeLoc-xstep probeLoc+xstep probeLoc+xstep probeLoc-xstep]; %centered at 1
    y1 = beginEndCluster(:,1).*channelSpacing;
    y2 = (beginEndCluster(:,2)+1).*channelSpacing;
    
    for clust = 1:numel(y1)
        yData = [y1(clust) y1(clust) y2(clust) y2(clust)];
        patch('XData', xData, 'YData', yData, 'FaceColor', faceColors{clust}, 'FaceAlpha', 0.5);
        hold on
    end
    
    set(currAxes, 'XLim',xLim, 'YLim', yLim);
    bgColor = get(get(currAxes,'Parent'),'Color');
    set(currAxes,'Color',bgColor);
    set(currAxes,'XColor', bgColor);
%     set(gca,'YGrid','on','YTick',yMajorGrid,...
%         'Layer','top', 'GridAlpha', 1, 'GridColor', 'k')
    

end

