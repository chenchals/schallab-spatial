function plotSdfs( sdfStruct channelOrder, figureTitle )
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
    figProps(1,:) = {maxChannels, 2, 'YLabel', 0, 'right', 'cap'};
    figProps(2,:) = {4, 8, 'Title', 0, 'center', 'bottom'};
    figProps = cell2table(figProps);
    figProps.Properties.VariableNames={'rows','cols','labelAxis','rotation','horizontalAlign','verticalAlign'};

    for figNo = 1:2
        figure('Units','normalized','Position',[0.1 0.1 0.7 0.7]);
        for orderIndex = 1:maxChannels
            chNo = channelOrder(orderIndex);
            win = multiUnit(chNo).sdfWindow;
            multiUnitSdf = multiUnit(chNo).sdf_mean;
            meanSubMultiUnitSdf = multiUnitSdf - mean(multiUnitSdf(1:100));
            singleUnitIndex = multiUnit(chNo).singleUnitIndices;
            if figNo == 1 %(2 cols, 32x1 1st col)
                subplot(figProps.rows(figNo),figProps.cols(figNo),orderIndex*2-1);
            else
                subplot(figProps.rows(figNo),figProps.cols(figNo),orderIndex);
            end
            % plot multiUnit
            %plot(win,multiUnitSdf,'-r','LineWidth',2)
            plot(win,meanSubMultiUnitSdf,'-r','LineWidth',2)
            if numel(singleUnitIndex)>0 && figNo == 2
                hold on
                % plot singleUnit
                singleUnitSdf = cell2mat({singleUnit(singleUnitIndex).sdf_mean}');
                plot(win,singleUnitSdf(1:end,:))
                line([0 0], [yMin  yMax], 'Color','k');
                xlim(gca,[xMin  xMax]);
                ylim(gca,[yMin  yMax]);
                legendLabels = regexp([singleUnit(singleUnitIndex).spikeId],'\d\d[a-z]','match');
                legend([legendLabels{:}],'Box','off');
                drawnow
            else
                % leave empty box
            end
            % Label axes
            %xlabel(sprintf('Chan#%02d',chNo),'FontWeight','bold','FontSize',12);
            hAxis = get(gca,figProps.labelAxis{figNo});
            set(hAxis,'String',sprintf('Chan#%02d',chNo),'FontWeight','bold','FontSize',12);
            set(hAxis,'Rotation',figProps.rotation(figNo),...
                'HorizontalAlignment',figProps.horizontalAlign{figNo},...
                'VerticalAlignment',figProps.verticalAlign{figNo});            
        end
        if figNo == 1
            bgColor = get(gcf,'defaultfigurecolor');
            allPlots = findobj(gcf,'type','axes');
            set(allPlots,'Box','off','XTickLabel',{},'YTickLabel',{},...
                'Color',bgColor);
            cellfun(@(x) set(x,'TickValues',[],'Color', bgColor),...
                get(allPlots,{'XAxis','YAxis'}));
             cellfun(@(x) set(x,'Color',[0.15 0.15 0.15]),get(allPlots,{'XLabel','YLabel'}));
        end
       if ~isempty(figureTitle)
           addFigureTitle(figureTitle);
       end
       drawnow
    end

end

function addFigureTitle(figureTitle)
  h = axes('Units','Normal','Position',[.05 .05 .90 .90],'Visible','off');
  set(get(h,'Title'),'Visible','on');
  title(figureTitle,'fontSize',20,'fontWeight','bold')
end
