
processedLocation ='/mnt/teba/Users/Chenchal/Jacob/clustering/processed/';
nhps = {
    'broca'
    'darwin'
    'darwink'
    'gauss'
    'helmholtz'
    'joule'
    };
sizeBins = [0:100:1600];

% funtion for creating distribution
sizeSpacingDist = @(x) deal(...
   sizeBins(:),... 
   histcounts(cell2mat(x.nhpClusters.clusterSize_um), sizeBins)',...
   histcounts(cell2mat(x.nhpClusters.distToNextCluster_um), sizeBins)'...
   );
%load stats
nhpClusters = struct();
for jj = 1:numel(nhps)
    nhp = nhps{jj};
    nhpClusters.(nhp) = load(fullfile(processedLocation,nhp,[nhp 'ClusterStats_thr_0_50.mat']));  
    [nhpClusters.(nhp).binEdges, nhpClusters.(nhp).clustSize, nhpClusters.(nhp).clustDist] = sizeSpacingDist(nhpClusters.(nhp));
end

for jj = 1:numel(nhps)
    nhp = nhps{jj};
    clustSizes=cell2mat(nhpClusters.(nhp).nhpClusters.clusterSize_um);
    clustSpacings=cell2mat(nhpClusters.(nhp).nhpClusters.distToNextCluster_um);
    step = 100;
    binStart = 0;
    sizeLimits = [binStart ceil(max(clustSizes)/step)*step];
    spacingLimits = [binStart ceil(max(clustSpacings)/step)*step];    
    [ sizeDist, sizeBins] = histcounts(clustSizes, 'BinLimits',sizeLimits, 'BinWidth', step);
    [ spacingDist, spacingBins] = histcounts(clustSpacings,'BinLimits',spacingLimits, 'BinWidth', step);
    
    [sizeBySpacingDist, xVals, yVals] = histcounts2(clustSizes,clustSpacings,...
        'XBinLimits',sizeLimits,'YBinLimits',spacingLimits,'BinWidth', step);
    nRows = size(sizeBySpacingDist,1);
    nCols = size(sizeBySpacingDist,2);
    %linearize Nrows x Mcolums 
    sizeBySpacingDist = sizeBySpacingDist(:);
    sizeBySpacingDist(sizeBySpacingDist==0)=NaN;
    % Linearize xVals to match sizeBySpacingDist
    xBins = xVals(xVals>0);
    xBins =  repmat(xBins,nCols,1); 
    xBins = xBins(:);
    % Linearize yVals to match sizeBySpacingDist
    yBins = yVals(yVals>0);
    yBins = repmat(yBins(:),nRows,1);
    % now plot size dist, spacing dist, sizebyspacing
    figure
    title(nhp)
    subplot(1,3,1)
    h = histogram('BinEdges', sizeBins+step/2, 'BinCounts',sizeDist);
    xlim([0 max(sizeBins)+step]);
    xticks([0:step*2:max(sizeBins)+step]);
    ylim([0 max(sizeDist)+1]);
    yticks([0:max(sizeDist)+1]);
    xlabel('Cluster size (um)')
    ylabel('Number of clusters')
    title('Distribution of cluster sizes')
    grid on
    
    subplot(1,3,2)
    h = histogram('BinEdges', spacingBins+step/2, 'BinCounts',spacingDist);
    xlim([0 max(spacingBins)+step]);
    xticks([0:step*2:max(spacingBins)+step]);
    ylim([0 max(spacingDist)+1]);
    yticks([0:max(spacingDist)+1]);
    xlabel('Distance to next cluster (um)')
    ylabel('Number of clusters')
    title('Distribution of distances to next cluster')
    grid on
    
    subplot(1,3,3)
    h = scatter(xBins,yBins,sizeBySpacingDist.*200,sizeBySpacingDist,'filled');
    xlim([0 max(xBins)+step]);
    xticks([0:step*2:max(xBins)+step]);
    ylim([0 max(yBins)+step]);
    yticks([0:step*2:max(yBins)+step]);
    xlabel('Cluster size (um)')
    ylabel('Distance to next cluster (um)')
    title('Distribution of cluster size by diatance to next cluster')
    grid on
    
end
