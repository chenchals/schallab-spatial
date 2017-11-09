function [ ] = plotDistanceMatHeatmap( im, channelMap, distMinMax, colorMap,  titleCell, titleColor )
%PLOTDISTANCEMATHEATMAP Summary of this function goes here
%   Detailed explanation goes here
    currAxes = gca;
    channelTicks = 4:4:numel(channelMap);
    channelTickLabels = arrayfun(@(x) ['#' num2str(channelMap(x))],channelTicks,'UniformOutput',false);

    imagescWithCluster(im,distMinMax,0.5,1,colorMap);
    currAxes.XTick = channelTicks;
    currAxes.XTickLabelRotation = 45;
%    currAxes.XTickLabel = 4:4:numel(channelMap);
    currAxes.YTick = channelTicks;
%    currAxes.YTickLabel = 4:4:numel(channelMap);
%    currAxes.YTickLabelRotation = 45;
    currAxes.FontSize = 18;
    set(gca,'XTickLabel',{' '})
    set(gca,'YTickLabel',{' '})


    
    currAxes.TickDir = 'out';

  %  pos = get(title(''),'Position');
  %  text(pos(1),pos(2)-1,titleCell,...
  %      'FontWeight','bold','FontAngle','italic','FontSize',14,'Color',titleColor,...
  %      'HorizontalAlignment', 'center', 'VerticalAlignment', 'bottom',...
  %      'Interpreter','none');

%    ylabel('Channel Number', 'FontWeight','bold', 'FontSize',24, 'Rotation', 45);
%    xlabel('Channel Number','FontWeight','bold', 'FontSize',24, 'Rotation', 45);
%    title('Correlated Spiking Activity','FontWeight','bold', 'FontSize',24);

    set(gca, 'XAxisLocation', 'top')


end

