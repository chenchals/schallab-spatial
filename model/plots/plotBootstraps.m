figure('Name', 'TargetOnset_AllNHPs_ClusterSizes_Bootstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(histBins,x),nhpSizeHist,'UniformOutput',0),...
    plot(histBins, allNhpSizeHist,'-m','LineWidth',2);
    title('Size of Clusters: 1000 Bootstrap Iterations');
    xlabel('Size of Clusters')
    ylabel('Number of Bootstrap Iterations')
    legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');
    set(gca,'FontSize',15)
    
% figure('Name', 'TargetOnset_AllNHPs_InterClusterDistances_Bootstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(histBins,x),nhpDistHist,'UniformOutput',0),...
%     plot(histBins, allNhpDistHist,'-m','LineWidth',2);
%     title('Size of Inter-Cluster Spacings: 1000 Bootstrap Iterations');
%     xlabel('Size of Inter-Cluster Spacings')
%     ylabel('Number of Bootstrap Iterations')
%     legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');    
%     set(gca,'FontSize',15)
%     
% figure('Name', 'TargetOnset_AllNHPs_NumClusters_Bootstrap', 'NumberTitle', 'off'); hold on, cellfun(@(x) plot(numHistBins,x),nhpNumHist,'UniformOutput',0),...
%     plot(numHistBins, allNhpNumHist,'-m','LineWidth',2);
%     xlim([0 10]);
%     title('Number of Clusters: 1000 Bootstrap Iterations');
%     xlabel('Number of Clusters')
%     ylabel('Number of Bootstrap Iterations')
%     legend('joule', 'broca', 'darwin', 'helmholtz', 'gauss', 'all');
%     set(gca,'FontSize',15)