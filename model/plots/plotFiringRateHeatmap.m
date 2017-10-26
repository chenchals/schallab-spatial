function [ ] = plotFiringRateHeatmap( im, channelMap, timeWin, frMinMax, colorMap,  titleCell, titleColor )
%PLOTFIRINGRATEHEATMAP Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
    channelTicks = 2:2:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks,'UniformOutput',false);

    imagescWithNan(im,frMinMax,[],1,colorMap);
    step = range(timeWin)/5;
    currAxes.XTick = 0:step:range(timeWin);
    currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):step:max(timeWin),'UniformOutput',false);

    align0 = find(min(timeWin):max(timeWin)==0);
    line([align0 align0], ylim, 'Color','r');

    currAxes.YTick = channelTicks;
    currAxes.YTickLabel = channelTickLabels;

    pos = get(title(''),'Position');
    %text(pos(1),pos(2),{upper(title), upper([firingRateHeatmap ' heatmap'])},...
    text(pos(1),pos(2),titleCell,...
        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColor,...
        'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
        'Interpreter','none');

    ylabel('Channel#','FontWeight','bold', 'FontSize',12);
    xlabel('time (ms)','FontWeight','bold', 'FontSize',12);

end

