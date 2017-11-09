function [ ] = plotFiringRateHeatmap( im, channelMap, timeWin, frMinMax, colorMap,  titleCell, titleColor )
%PLOTFIRINGRATEHEATMAP Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
    channelTicks = 4:4:numel(channelMap);
 %   channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks,'UniformOutput',false);

    imagescWithNan(im,frMinMax,[],1,colorMap);
     step = range(timeWin)/5;
     xTick = 1:50:numel(timeWin);
     
     currAxes.XTick = xTick;
%     currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):50:numel(timeWin),'UniformOutput',false);
     currAxes.TickDir = 'out';
     currAxes.FontSize = 16;
    
    align0 = find(min(timeWin):max(timeWin)==0);
    line([align0 align0], ylim, 'Color','r','LineWidth',3);

     currAxes.YTick = channelTicks;
%     currAxes.YTickLabel = 4:4:numel(channelMap);
%     currAxes.FontSize = 16;
    set(gca,'XTickLabel',{' '})
    set(gca,'YTickLabel',{' '})
    
    %pos = get(title(''),'Position');
    %text(pos(1),pos(2),{upper(title), upper([firingRateHeatmap ' heatmap'])},...
    %text(pos(1),pos(2),titleCell,...
    %    'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColor,...
    %    'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
    %    'Interpreter','none');

%    ylabel('Channel Number','FontWeight','bold', 'FontSize',24);
%    xlabel('Time From Target Onset (ms)','FontWeight','bold', 'FontSize',24);
    %title('Normalized Firing Rate','FontWeight','bold', 'FontSize',32);

end

