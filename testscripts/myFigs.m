pos =[
    0.055 0.455 0.113 0.50
    0.166 0.455 0.113 0.50
    0.333 0.455 0.225 0.50
    ];    

plot1data = overall.contra_targetOnset_right.sdfMeanZtr;
plot2data = overall.contra_responseOnset_right.sdfMeanZtr;
plot3data = overall.rsquared;

    axesHandles = createFig(pos);
    figH = get(axesHandles(1),'Parent');
    set(figH, 'currentaxes',axesHandles(1))
    imagesc(plot1data)
        set(axesHandles(1),'YTick',[2:2:32], 'YTickLabel',repmat('haha',16,1),'box', 'off')

    
    
    set(figH, 'currentaxes',axesHandles(2))
    imagesc(plot2data)
    set(axesHandles(2),'YTick',[], 'box', 'off')
    
    
    set(figH, 'currentaxes',axesHandles(3))
    imagesc(plot3data)    

    
    
    
%     %% session    
%     session = load(heDak{s});
%     sessionFields = fieldnames(session);
%     currCond = sessionFields{contains(sessionFields,cond)};
%     channelMap = session.channelMap;
%     %% Firing Rate
%     timeWin = session.(currCond).sdfWindow;
%     fr = session.(currCond).sdfMeanZtr;
%     frMinMax = minmax(fr(:)');
%     set(figH, 'currentaxes',axesHandles(1))
%     plotFiringRateHeatmap(fr,channelMap,timeWin,frMinMax,'jet',{'contra_responseOnset', 'sdfMeanZtr Heatmap'},'r');
%     colorbar('off');
%     %% distMat
%     distMat = session.(currCond).rsquared;
%     distMinMax = minmax(distMat(:)');
%     set(figH, 'currentaxes',axesHandles(2))
%     plotDistanceMatHeatmap(distMat,channelMap,distMinMax,'cool',{'contra_responseOnset', 'rsquared heatmap'},'r');
%     
%     %% Probe
%     [boc, eoc] = clusterIt(diag(distMat,1),0.5);
%     bocEoc = [boc(:), eoc(:)];
%     set(figH, 'currentaxes',axesHandles(3))
%     plotProbe(1,session.info.channelSpacing,channelMap,bocEoc,true);
%     
%     %% Infos
%     infos = session.info;
%     set(figH, 'currentaxes',axesHandles(4))
%     set(gca,'box','on','XTick',[],'YTick',[]);
%     addInfo(infos);
%     h = title(session.session, 'FontWeight','bold', 'FontSize',15,'Interpreter','none');
%     
%     drawnow
%     %% Save figs
%     [~,fn,~] = fileparts(heDak{s});
%     
%     oFile = fullfile(outDir,[fn '_' cond]);
%     fprintf('Saving figure to file %s\n',oFile);
%     %saveas(figH,oFile,'jpg');
%     %saveas(figH,oFile, 'fig');


function [axesHandles] = createFig(axesPositions)
    figure('Units','normalized','Position',[0.05 0.05 0.80 0.80]);
    for ii = 1:size(axesPositions,1)
        axesHandles(ii) = axes('Position',axesPositions(ii,:),'Units','normalized');
    end
end

function addInfo(infoTable)
    currAxes = gca;
    currAxes.XTick = [];
    currAxes.YTick = [];
    currAxes.Visible = 'on';
    currAxes.Box = 'on';
    varNames=infoTable.Properties.VariableNames;
    % remove channelMap from varnames
    varNames = varNames(~contains(varNames,{'ephysChannelMap' 'rawPath' 'matPath'}));
    propsPerCol = 10;
    fontSize = 12;
    columnGap = 0.02;
    nCols = ceil(numel(varNames)/propsPerCol)+1;
    xPos=0.01;
    yPos = 0.9;
    for c = 1:nCols-1 % last col channelMap
        t = cell(propsPerCol,1);
        ind = (c-1)*propsPerCol+1:c*propsPerCol;
        ind = ind(ind<=numel(varNames));
        for i = 1:numel(ind)
            name = varNames{ind(i)};
            value = infoTable.(name);
            if isnumeric(value)
                value = num2str(value);
            else
                value = char(value);
            end
            t{i} = [name,' : ',value];
        end
        hText = text(xPos,yPos,t,'Interpreter','none',...
            'FontWeight','bold','FontSize',fontSize,...
            'VerticalAlignment', 'top','HorizontalAlignment','left');
        xPos = getNextXPos(hText, columnGap);
    end
    chanMap = infoTable.ephysChannelMap{:};
    chanRows = 4;
    chanCols = ceil(numel(chanMap)/chanRows);
    hText = text(xPos,yPos,{'ePhysChannelMap'; ...
        num2str(reshape(chanMap,chanCols,chanRows)','%02d, ')},...
        'Interpreter','none','FontWeight','bold','FontSize',fontSize,...
        'VerticalAlignment', 'top','HorizontalAlignment','left');
end

%% Get next X position fron the previous plot extens
function [ xPos ] = getNextXPos(hText, columnGap)
        xPos = get(hText,'Extent');
        xPos = xPos(1) + xPos(3) + columnGap;
end

%% Figure1:
% Make da_k1 and da_k2 : targetOnset [-50  300]
% clustering : 
% 1. use absolute distance not channel number
%    use threshold of absolute distance to call a cluster
% 2. Bum channel: 
% 3. criteria: all channels are clusters to one cluster
% 4. plot of gaps vs criteria Versus plot of clusters size vs criteria
% 
%     templateName = '/Users/chenchals/Projects/lab-schall/schalllab-spatial/other/grant/example/windowSmall/grantsFigTemplate.m';
%     cmd = ['grep -A 1 "Tag.*axes" ' templateName ' | grep "Position" | cut -d , -f 2'];
%     [a,z] = system(cmd)
%     