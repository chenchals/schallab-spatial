
nhps = fieldnames(ZZ);

% for each NHP get distribution of 
% cluster sizes from bootss for all sessions per condition
for ii = 1:numel(nhps)
    nhp = nhps{ii};
    sessions = fieldnames(ZZ.(nhp));   
    cSizes = cellfun(@(x) [ZZ.(nhp).(char(x)).contra_responseOnset.boots.cSize], sessions,'UniformOutput',false);
    cDists = cellfun(@(x) [ZZ.(nhp).(char(x)).contra_responseOnset.boots.dtnc], sessions,'UniformOutput',false);
    cNums = cellfun(@(x) cellfun(@length,{ZZ.(nhp).(x).contra_responseOnset.boots.cSize}),sessions,'UniformOutput',false);    
    
    nhpCSizes{ii} = [cSizes{:}];
    nhpCDists{ii} = [cDists{:}];
    nhpCNums{ii} = [cNums{:}];

end

% all monks
nhpSizes = [nhpCSizes{:}];
nhpDists = [nhpCDists{:}];
nhpNums = [nhpCNums{:}];

% Statistics
nhpCSizeStats = getStats(nhps, nhpCSizes);
nhpCDistStats = getStats(nhps, nhpCDists);
nhpCNumStats = getStats(nhps, nhpCNums);

nhpSizeStats = getStats({'Global'},{nhpSizes});
nhpDistStats = getStats({'Global'},{nhpDists});
nhpNumStats = getStats({'Global'},{nhpNums});

sizeStats = [nhpCSizeStats;nhpSizeStats];
distStats = [nhpCDistStats;nhpDistStats];
numStats = [nhpCNumStats;nhpNumStats];

writetable(sizeStats,'ClusterStats_alignOnresponseOnset_boots.xlsx','Sheet','boots_clust_size','WriteRowNames',true,'WriteVariableNames',true)
writetable(distStats,'ClusterStats_alignOnresponseOnset_boots.xlsx','Sheet','boots_clust_dist','WriteRowNames',true,'WriteVariableNames',true)
writetable(numStats,'ClusterStats_alignOnresponseOnset_boots.xlsx','Sheet','boots_clust_num','WriteRowNames',true,'WriteVariableNames',true)




% individual monks
histBins = 0:100:(ceil(max(nhpSizes)/100)*100+100);
nhpSizeHist = cellfun(@(x) histc(x,histBins),nhpCSizes,'UniformOutput',0);
nhpDistHist = cellfun(@(x) histc(x,histBins),nhpCDists,'UniformOutput',0);
numHistBins = 1:32;
nhpNumHist = cellfun(@(x) histc(x,numHistBins),nhpCNums,'UniformOutput',0);

% all monks
allNhpSizeHist = histc(nhpSizes,histBins);
allNhpDistHist = histc(nhpDists,histBins);
allNhpNumHist  = histc(nhpNums,numHistBins);

% 
% figure('Name', 'responseOnset_AllNHPs_ClusterSizes_bootsstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(histBins,x),nhpSizeHist,'UniformOutput',0),...
%     plot(histBins, allNhpSizeHist,'-m','LineWidth',2);
%     title('Size of Clusters: 1000 bootsstrap Iterations');
%     xlabel('Size of Clusters')
%     ylabel('Number of bootsstrap Iterations')
%     legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');
%     set(gca,'FontSize',15)
%     
% figure('Name', 'responseOnset_AllNHPs_InterClusterDistances_bootsstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(histBins,x),nhpDistHist,'UniformOutput',0),...
%     plot(histBins, allNhpDistHist,'-m','LineWidth',2);
%     title('Size of Inter-Cluster Spacings: 1000 bootsstrap Iterations');
%     xlabel('Size of Inter-Cluster Spacings')
%     ylabel('Number of bootsstrap Iterations')
%     legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');    
%     set(gca,'FontSize',15)
%     
% figure('Name', 'responseOnset_AllNHPs_NumClusters_bootsstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(numHistBins,x),nhpNumHist,'UniformOutput',0),...
%     plot(numHistBins, allNhpNumHist,'-m','LineWidth',2);
%     xlim([0 10]);
%     title('Number of Clusters: 1000 bootsstrap Iterations');
%     xlabel('Number of Clusters')
%     ylabel('Number of bootsstrap Iterations')
%     legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');
%     set(gca,'FontSize',15)
%     

    
%Stats