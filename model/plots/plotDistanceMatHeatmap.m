function [ ] = plotDistanceMatHeatmap( im, channelMap, distMinMax, colorMap,  titleCell, titleColor )
%PLOTDISTANCEMATHEATMAP Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
    channelTicks = 2:2:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks,'UniformOutput',false);

    imagescWithCluster(im,distMinMax,0.5,1,colorMap);
    currAxes.XTick = channelTicks;
    currAxes.XTickLabelRotation = 0;
    currAxes.XTickLabel = 2:2:numel(channelMap);
    currAxes.YTick = channelTicks;
    currAxes.YTickLabel = 2:2:numel(channelMap);
    
    currAxes.TickDir = 'out';

  %  pos = get(title(''),'Position');
  %  text(pos(1),pos(2)-1,titleCell,...
  %      'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColor,...
  %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
  %      'Interpreter','none');

    ylabel('Channel Number', 'FontWeight','bold', 'FontSize',12);
    xlabel('Channel Number','FontWeight','bold', 'FontSize',12);
    %title('Correlated Spiking Activity','FontWeight','bold', 'FontSize',24);



end

