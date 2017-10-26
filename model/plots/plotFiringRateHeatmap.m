function [ output_args ] = plotFiringRateHeatmap( input_args )
%PLOTFIRINGRATEHEATMAP Summary of this function goes here
%   Detailed explanation goes here

    im = currPlots{1};
    imagescWithNan(im,frMinMax,[],1,colorbarNames{1});
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

end

