function [ ] = plotDistanceMatHeatmap( im, channelMap, distMinMax, colorMap,  titleCell, titleColor )
%PLOTDISTANCEMATHEATMAP Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
    channelTicks = 2:2:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks,'UniformOutput',false);

    imagescWithCluster(im,distMinMax,0.5,1,colorMap);
    currAxes.XTick = channelTicks;
    currAxes.XTickLabelRotation = 90;
    currAxes.XTickLabel = channelTickLabels;
    currAxes.YTick = channelTicks;
    currAxes.YTickLabel = channelTickLabels;
    
    currAxes.TickDir = 'out';

    pos = get(title(''),'Position');
    text(pos(1),pos(2),titleCell,...
        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColor,...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
        'Interpreter','none');

    ylabel('Channel#','FontWeight','bold', 'FontSize',12);
    xlabel('Channel#','FontWeight','bold', 'FontSize',12);


end

