function [ MI ] = exploreSpatialAnalysis()
jp60 = load('/Volumes/Macintosh HD/Users/elseyjg/temp/schalllab-spatial/processed/joule/jp124n01.mat');

sess = jp60;
fNames = fieldnames(sess);
% xValsToUse = choices are: 'R^2', 'sdf Mean FR', 'sdf Mean FR (Z)',
% 'sdf Mean Ztr'
xValsToUseArr = {'R^2','sdf Mean Ztr','sdf Mean FR (Z)','sdf Mean FR'};

    for xx = 1: numel(xValsToUseArr)
        xValToUse = xValsToUseArr{xx};

        xValToUse_fieldName = regexprep(xValToUse,'[^A-Za-z0-9]','');
        % Distance threshold
        neighborDistanceStep = 100; % in microns
        dists = [2 5 7]; % distances to use
        connectivityFx = localfunctions;
        % Only those functions that contain suffix Fx
        connectivityFx = connectivityFx(contains(cellfun(@func2str,connectivityFx,'UniformOutput',false),'Fx'));

        conds = {'contra_targetOnset';'contra_responseOnset';'ipsi_targetOnset';'ipsi_responseOnset'};
        sessConds = fNames(contains(fNames,conds));

        for ii = 1:numel(sessConds)
            cond = sessConds{ii};
            switch xValToUse
                case 'R^2'
                    sdfMeanZtr = sess.(cond).sdfMeanZtr;
                    rsquared = corr(sdfMeanZtr',sdfMeanZtr').^2;
                    % Since there will be n-1 correlations, prefix 1 for self correlation
                    xVlasForMoran = [1; diag(rsquared,1)];
                case 'sdf Mean Ztr'
                    sdfMeanZtr = sess.(cond).sdfMeanZtr;
                    xVlasForMoran = mean(sdfMeanZtr,2);
                case 'sdf Mean FR (Z)'
                    sdfMean = sess.(cond).sdfMean;
                    xVlasForMoran = mean(sdfMean,2);
                    xVlasForMoran = zscore(xVlasForMoran);
                case 'sdf Mean FR'
                    sdfMean = sess.(cond).sdfMean;
                    xVlasForMoran = mean(sdfMean,2);
            end

            nChannels = numel(xVlasForMoran);
            distance = sess.info.channelSpacing*[0:nChannels-1];

            for dd = 1:numel(dists)
                neighborDistance = dists(dd)*neighborDistanceStep;
                neighborFx = connectivityFx{2}(distance,neighborDistance);
                weightMat = getSymmetricWeightMat(neighborFx);
                mi.(cond)(dd).distance = distance;
                mi.(cond)(dd).neighborDistance = neighborDistance;
                mi.(cond)(dd).x = xVlasForMoran;
                mi.(cond)(dd).neighborFx = neighborFx;
                mi.(cond)(dd).weightMat = weightMat;
                mi.(cond)(dd).moran = moransad(xVlasForMoran,ones(numel(xVlasForMoran),1),weightMat,'W','gl','n');
                Z = [mi.(cond)(dd).moran.z_mi mi.(cond)(dd).moran.prob_nv];
                Z(:,3) = Z(:,2);
                Z(Z(:,1)>1,3) = 1 - Z(Z(:,1)>1,2);
                mi.(cond)(dd).moran.alpha = Z(:,3);
            end
        end
        plotMoransFig(sess, mi, dists, xValToUse)
        MI.(xValToUse_fieldName) = mi;
    end
end

% Plot moran's figure
function [] = plotMoransFig(sess, mi, dists, xValsToUse)
    % Plot these
    mainFig = figure;
    set(mainFig,'Name',[sess.session ' - ' xValsToUse])
    fn = sortrows(fieldnames(mi));
    nPlotRows = numel(fn) + 1 ;
    nPlotCols = numel(dists) + 2;
    plotNum = 0;
    for c = 1: nPlotRows-1
        currCond = fn{c};
        currMi = mi.(currCond);
        x = currMi(1).x;
        distance = currMi(1).distance;
        [yTickIndices, yTicks, yTickLabels] = getTicks(distance);
        plotNum = plotNum + 1; subplot(nPlotRows,nPlotCols,plotNum)
        imagesc(x);
        colormap('cool')
        colorbar
        titleTxt{1} = regexprep(currCond,'_','-');
        titleTxt{2} = xValsToUse;
        title(titleTxt,'Interpreter','tex');
        set(gca,'XLim', [0.5 1],'XTick',[],'YTick', yTickIndices,'YTickLabel',yTickLabels)  
        % Plot diag
        plotNum = plotNum + 1; subplot(nPlotRows,nPlotCols,plotNum)
        plot(x,distance(:));
        set(gca,'YDir','reverse')
        set(gca,'YLim',[0 max(distance)])
        set(gca,'YTick', yTicks,'YTickLabel',yTickLabels,'YGrid','on','YMinorGrid','on')
        xlabel(xValsToUse)
        title(xValsToUse);

        for p = 1:numel(dists)
            neighborDistance = currMi(p).neighborDistance;
            distance = currMi(p).distance;
            moranI = currMi(p).moran.mi;
            alpha = currMi(p).moran.alpha;
            plotNum = plotNum + 1; 
            subplot(nPlotRows,nPlotCols,plotNum)
            plotMoran(neighborDistance,distance,moranI,alpha);        
        end
    end
    drawnow
    % For the last row of plots
    % plot the neighbor function used
    fn = sortrows(fieldnames(mi));
    nFx = {mi.(fn{1}).neighborFx};
    nDist = {mi.(fn{1}).distance};
    nLegs = cell2mat({mi.(fn{1}).neighborDistance})';
    yVals = nDist{1};
    plotNum = plotNum +2 ; % offset for last row
    subplot(nPlotRows,nPlotCols,plotNum)
    plot(cell2mat(nFx'),yVals)
    yTickIndices = 0:4:numel(yVals)-1;
    yTicks = yVals(yTickIndices+1);
    yTickLabels = arrayfun(@num2str,yTicks,'UniformOutput',false);
    legend(strcat(num2str(nLegs,'%d'),' \mum'),'Location','southeast');
    title('Neighbor Function');
    set(gca,'YTick', yTicks,'YTickLabel',yTickLabels, 'YGrid', 'on', 'YMinorGrid','on')
    set(gca,'YDir','reverse')
    set(gca,'YLim',[0 max(yVals)])
    set(gca,'XLim',[0 1], 'XGrid','on')
    xlabel('Neighbor influence (?)')
    % weight matrices
    nWeightMat = {mi.(fn{1}).weightMat};    
    for p = 1:numel(nFx)
        plotNum = plotNum +1;
        subplot(nPlotRows,nPlotCols,plotNum)
        currAxes = gca;
        imagesc(nWeightMat{1})        
        currAxes.TickDir = 'out';  
        currAxes.Box = 'on';
        currAxes.XTick = yTickIndices;
        currAxes.XTickLabel = yTickLabels;
        currAxes.XTickLabelRotation = 90;
        currAxes.YTick = yTickIndices;
        currAxes.YTickLabel = yTickLabels;
        currAxes.XGrid = 'on';
        currAxes.XMinorGrid = 'on';
        currAxes.YGrid = 'on';
        currAxes.YMinorGrid = 'on';
                 
        title('Weight Matrix');
    end
    
    axes(mainFig,'Visible','off') ;
    th = title([sess.session ' - ' xValsToUse],'Visible','on','FontSize',16,'FontWeight','bold');
    p=get(th,'Position');
    p1=p;p1(2)=p1(2)*1.05;
    set(th,'Position',p1);
    drawnow
end

function [] = plotMoran(neighborDistance, distanceVec, moranIVec, alphaVec)
    gMoran = moranIVec(1);
    gAlphaMoran = alphaVec(1);
    lMoran = moranIVec(2:end);
    lAlphaMoran =  alphaVec(2:end);
    plot(lMoran,distanceVec,'o-')
    xLims = [floor(min(lMoran)*10)/10 ceil(max(lMoran)*10)/10];
    if gAlphaMoran < 0.01
        titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f') '^{**}'];
    elseif gAlphaMoran < 0.05
        titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f') '^*'];
    else
        titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f')];
    end
    titleTxt{2} = [num2str(neighborDistance) '\mum'];
    title(titleTxt,'Interpreter','tex');
    [~, yTicks, yTickLabels] = getTicks(distanceVec);
    set(gca,'YTick', yTicks,'YTickLabel',yTickLabels,'YGrid','on','YMinorGrid','on')
    set(gca,'YDir','reverse')
    set(gca,'YLim',[0 max(distanceVec)])
    set(gca,'XLim',xLims)
    xlabel('MI\it_{Local}')
    line([0 0],[0 max(distanceVec)],'Color','k','LineStyle','--','LineWidth',1)
    line([gMoran gMoran],[0 max(distanceVec)],'Color','r','LineStyle','--','LineWidth',2)
    % Significant
    sig = find(lAlphaMoran < 0.05);
    if numel(sig)>0
        text(lMoran(sig),distanceVec(sig),'*', 'FontSize',18, 'Color','r')
    end
    sig = find(lAlphaMoran < 0.01);
    if numel(sig)>0
        text(lMoran(sig),distanceVec(sig),'**', 'FontSize',18, 'Color','r')
    end

end

function [tickIndices, ticks, tickLabels] = getTicks(distance)
    tickIndices = 1:4:numel(distance);
    ticks = distance(tickIndices);
    tickLabels = arrayfun(@num2str,ticks,'UniformOutput',false);
end

% set all locations at and below threshold to 1 and rest to zero
function [ outVec ] = squareFx(distances, threshold)
    outVec = zeros(1, numel(distances));
    outVec(distances<=threshold) = 1;
end

% For weight matrix
% set a exponetial decay function for neighbor influence falls to 1/e at
% the threshold distance
function [ outVec ] = negativeExpDecayFx(distances, threshold)
    outVec = exp(-(distances/threshold));
end

% Create weight Matrix with neighbor function vector
function [ wMat ] = getSymmetricWeightMat(neighborFx)
    n = numel(neighborFx);
    wMat = zeros(n,n);
    for ii = 1:n
        wMat(ii,ii:n) = neighborFx(1:n-ii+1);
    end
    % Make the matrix symmetric
    wMat = wMat' + wMat;
    % ensure diag is zero
    wMat(1:n+1:end) = 0;
end
