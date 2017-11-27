function [ mi ] = exploreSpatialAnalysis()
jp60 = load('/Volumes/Macintosh HD/Users/elseyjg/temp/schalllab-spatial/processed/joule/jp124n01.mat');

sess = jp60;
fNames = fieldnames(sess);
% r_squared threshold
% r_squares < threshold = 0 and r_squared >= threshold = 1
r_sq_threshold = 0.5;
% change r_squared to binary values based on threshold?
binarize = false;
% Distance threshold
neighborDistanceStep = 100; % in microns
dists = [2 5 7]; % distances to use
connectivityFx = localfunctions;
% Only those functions that contain suffix Fx
connectivityFx = connectivityFx(contains(cellfun(@func2str,connectivityFx,'UniformOutput',false),'Fx'));

conds = {'contra_targetOnset';'contra_responseOnset';'ipsi_targetOnset';'ipsi_responseOnset'};
sessConds = fNames(contains(fNames,conds));

%for ii = 1:numel(sessConds)
for ii = 1:numel(sessConds)
    
    cond = sessConds{ii};
    sdfMeanZtr = sess.(cond).sdfMeanZtr;
    rsquared = corr(sdfMeanZtr',sdfMeanZtr').^2;
    % Since there will be n-1 correlations, prefix 1 for self correlation
    d1 = [1; diag(rsquared,1)];
    d1Ztr = mean(sdfMeanZtr,2);
    % binarize d1
    binaryD1 = d1;
    if binarize
        binaryD1(binaryD1>=r_sq_threshold) = 1;
        binaryD1(~(binaryD1>=r_sq_threshold)) = 0;
    end
    
    nChannels = numel(binaryD1);
    distance = sess.info.channelSpacing*[0:nChannels-1];
    
    for dd = 1:numel(dists)
        neighborDistance = dists(dd)*neighborDistanceStep;
        neighborFx = connectivityFx{2}(distance,neighborDistance);
        weightMat = getSymmetricWeightMat(neighborFx);
        mi.(cond)(dd).binarize = binarize;
        mi.(cond)(dd).distance = distance;
        mi.(cond)(dd).neighborDistance = neighborDistance;
        mi.(cond)(dd).x = binaryD1;
        mi.(cond)(dd).neighborFx = neighborFx;
        mi.(cond)(dd).weightMat = weightMat;
        mi.(cond)(dd).moran = moransad(binaryD1,ones(numel(binaryD1),1),weightMat,'W','gl','n');
        Z = [mi.(cond)(dd).moran.z_mi mi.(cond)(dd).moran.prob_nv];
        Z(:,3) = Z(:,2);
        Z(Z(:,1)>1,3) = 1 - Z(Z(:,1)>1,2);
        mi.(cond)(dd).moran.alpha = Z(:,3);
    end
end
    
    % Plot these
    mainFig = figure;
    set(mainFig,'Name',[sess.session])
    fn = sortrows(fieldnames(mi));
    nPlotRows = numel(fn);
    nPlotCols = numel(dists) + 2;
    plotNum = 0;
    for c = 1: nPlotRows
        currCond = fn{c};
        currMi = mi.(currCond);
        x = currMi(1).x;
        distance = currMi(1).distance;
        distanceTicks = distance(1:4:numel(distance));
        distanceTickLabels = arrayfun(@num2str,distanceTicks,'UniformOutput',false);
        plotNum = plotNum + 1; subplot(nPlotRows,nPlotCols,plotNum)
        imagesc(x);
        colormap('cool')
        colorbar
        title('R^2 Heatmap','Interpreter','tex')
        text(0.75,-4.0,currCond,'FontSize',14,'FontWeight','bold','Interpreter','none','HorizontalAlignment','center')
        set(gca,'XLim', [0.5 1],'XTick',[],'YTick', distanceTicks,'YTickLabel',distanceTickLabels)  
        % Plot diag
        plotNum = plotNum + 1; subplot(nPlotRows,nPlotCols,plotNum)
        plot(x,distance(:));
        set(gca,'YDir','reverse')
        set(gca,'YLim',[0 max(distance)])
        set(gca,'YTick', distanceTicks,'YTickLabel',distanceTickLabels)
        xlabel('R^2')
        title('R^2')
        plotXlims=zeros(numel(dists),2);
        for p = 1:numel(dists)
            plotNum = plotNum + 1; subplot(nPlotRows,nPlotCols,plotNum)
            gMoran = currMi(p).moran.mi(1);
            lMoran = currMi(p).moran.mi(2:end);
            plotXlims(p,:) = [floor(min(lMoran)*10)/10 ceil(max(lMoran)*10)/10];
            alphaMoran =  currMi(p).moran.alpha(2:end);
            plot(lMoran,distance,'o-')
            if currMi(p).moran.alpha(1) < 0.01 
              titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f') '^{**}'];
            elseif currMi(p).moran.alpha(1) < 0.05
              titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f') '^*'];
            else
              titleTxt{1} =['MI\it_G = ' num2str(gMoran,'%0.4f')];
            end
            titleTxt{2} = [num2str(currMi(p).neighborDistance) '\mum'];
            title(titleTxt,'Interpreter','tex');
            set(gca,'YTick', distanceTicks,'YTickLabel',distanceTickLabels)        
            set(gca,'YDir','reverse')
            set(gca,'YLim',[0 max(distance)])
            set(gca,'XLim',plotXlims(p,:))
            xlabel('MI\it_{Local}')
            line([0 0],[0 max(distance)],'Color','k','LineStyle','--','LineWidth',1)
            line([gMoran gMoran],[0 max(distance)],'Color','r','LineStyle','--','LineWidth',2)
            % Significant
            sig = find(alphaMoran < 0.05);
            if numel(sig)>0 
                text(lMoran(sig),distance(sig),'*', 'FontSize',18, 'Color','r')
            end
            sig = find(alphaMoran < 0.01);
            if numel(sig)>0
                text(lMoran(sig),distance(sig),'**', 'FontSize',18, 'Color','r')
            end
            
        end
        % set lim for each condition
        %mi.(currCond)
        
        %set(gca,'XLim',[-1.5 1.5])
        set(findobj('type','axes'),'YGrid','on','YMinorGrid','on')
    end
    axes(mainFig,'Visible','off') ;
    th = title(sess.session,'Visible','on','FontSize',16,'FontWeight','bold');
    p=get(th,'Position');
    p1=p;p1(2)=p1(2)*1.05;
    set(th,'Position',p1)
end

%end
% For weight matrix
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
% Mak the matrix symmetric
wMat = wMat' + wMat;
% ensure diag is zero
wMat(1:n+1:end) = 0;
end
