function plotSdfs( multiUnit, singleUnit, channelOrder )
%PLOTSDFS Summary of this function goes here
%   Detailed explanation goes here
% neuronexusMap = ([9:16,25:32,17:24,1:8])

    %% Plot multi-unit along with single unit SDF_mean
    % make 2 plots
    % round to the next nearest 10 ms
    roundToNextNms = 10;
    yMin = floor(min([multiUnit.sdf_mean])/roundToNextNms)*roundToNextNms;
    yMax = ceil(max([multiUnit.sdf_mean])/roundToNextNms)*roundToNextNms;
    xMin = floor(min([multiUnit.sdfWindow])/roundToNextNms)*roundToNextNms;
    xMax = ceil(max([multiUnit.sdfWindow])/roundToNextNms)*roundToNextNms;
    maxChannels = numel(channelOrder);
    % Setup figure properties
    figProps(1,:) = {1, maxChannels, 90, 'right', 'cap'};
    figProps(2,:) = {4, 8, 0, 'center', 'bottom'};
    figProps = cell2table(figProps);
    figProps.Properties.VariableNames={'rows','cols','rotation','horizontalAlign','verticalAlign'};

    for figNo = 1:2
        figure('Units','normalized','Position',[0.1 0.1 0.7 0.7]);
        for orderIndex = 1:maxChannels
            chNo = channelOrder(orderIndex);
            subplot(figProps.rows(figNo),figProps.cols(figNo),orderIndex);
            win = multiUnit(chNo).sdfWindow;
            mu = multiUnit(chNo).sdf_mean;
            suIndex = multiUnit(chNo).singleUnitIndices;
            if numel(suIndex)>0
                su = cell2mat({singleUnit(suIndex).sdf_mean}');
                plot(win,mu,'-r','LineWidth',2)
                hold on
                plot(win,su(1:end,:))
                line([0 0], [yMin  yMax], 'Color','k');
                xlim(gca,[xMin  xMax]);
                ylim(gca,[yMin  yMax]);
                xlabel(sprintf('Chan#%02d',chNo),'FontWeight','bold','FontSize',12);
                set(get(gca,'XLabel'),'Rotation',figProps.rotation(figNo),...
                    'HorizontalAlignment',figProps.horizontalAlign{figNo},...
                    'VerticalAlignment',figProps.verticalAlign{figNo});
            else
                % leave empty box
            end
            drawnow
        end
        %set(findobj('type','axes'),'YLim',[yMin  yMax]);
        %set(findobj('type','axes'),'XLim',[xMin  xMax]);
    end

end

