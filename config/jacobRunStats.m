
nhps = fieldnames(ZZ);

% for each NHP get distribution of 
% cluster sizes from boots for all sessions per condition
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

for ii = 1:numel(nhps)
    nhp = nhps{ii};
    sessions = fieldnames(ZZ.(nhp));   
    cSizesObserved = cellfun(@(x) [ZZ.(nhp).(char(x)).contra_responseOnset.observed.cSize], sessions,'UniformOutput',false);
    cDistsObserved = cellfun(@(x) [ZZ.(nhp).(char(x)).contra_responseOnset.observed.dtnc], sessions,'UniformOutput',false);
    cNumsObserved = cellfun(@(x) cellfun(@length,{ZZ.(nhp).(x).contra_responseOnset.observed.cSize}),sessions,'UniformOutput',false);    
    
    nhpCSizesObserved{ii} = [cSizesObserved{:}];
    nhpCDistsObserved{ii} = [cDistsObserved{:}];
    nhpCNumsObserved{ii} = [cNumsObserved{:}];

end


% all monks
nhpSizes = [nhpCSizes{:}];
nhpDists = [nhpCDists{:}];
nhpNums = [nhpCNums{:}];

nhpSizesObserved = [nhpCSizesObserved{:}];
nhpDistsObserved = [nhpCDistsObserved{:}];
nhpNumsObserved = [nhpCNumsObserved{:}];

% individual monks
histBins = 0:100:(ceil(max(nhpSizes)/100)*100+100);
nhpSizeHist = cellfun(@(x) histc(x,histBins),nhpCSizes,'UniformOutput',0);
nhpDistHist = cellfun(@(x) histc(x,histBins),nhpCDists,'UniformOutput',0);
numHistBins = 1:32;
nhpNumHist = cellfun(@(x) histc(x,numHistBins),nhpCNums,'UniformOutput',0);

histBins = 0:100:(ceil(max(nhpSizes)/100)*100+100);
nhpSizeHistObserved = cellfun(@(x) histc(x,histBins),nhpCSizesObserved,'UniformOutput',0);
nhpDistHistObserved = cellfun(@(x) histc(x,histBins),nhpCDistsObserved,'UniformOutput',0);
numHistBins = 1:32;
nhpNumHistObserved = cellfun(@(x) histc(x,numHistBins),nhpCNumsObserved,'UniformOutput',0);

% all monks
allNhpSizeHist = histc(nhpSizes,histBins);
allNhpDistHist = histc(nhpDists,histBins);
allNhpNumHist  = histc(nhpNums,numHistBins);

allNhpSizeHistObserved = histc(nhpSizesObserved,histBins);
allNhpDistHistObserved = histc(nhpDistsObserved,histBins);
allNhpNumHistObserved  = histc(nhpNumsObserved,numHistBins);



    for ii = 1:numel(nhps)
        nhp = nhps{ii};
        a(ii) = figure(ii);
        set(a(ii),'Name', ['responseOnset_',nhp,'_ClusterSizes']); 
        hold on; 
        plot(histBins,nhpSizeHist{ii}./sum(nhpSizeHist{ii}), 'LineWidth', 2);
        set(gca,'FontSize',16);
 %       xlabel('Size of Clusters (um)','FontSize',20, 'FontWeight', 'bold')
 %       ylabel('Proportion Observed','FontSize',20, 'FontWeight', 'bold')
        plot(histBins,nhpSizeHistObserved{ii}./sum(nhpSizeHistObserved{ii}), 'LineWidth', 2);
        set(gca,'FontSize',16);
 %       title(['Size of Clusters (um)__',nhp], 'FontSize',24, 'FontWeight', 'bold');
 %       xlabel('Size of Clusters (um)', 'FontSize',20, 'FontWeight', 'bold')
 %       ylabel('Proportion Observed', 'FontSize',20, 'FontWeight', 'bold')
        legend('Bootstrapped','Observed');
        set(gca,'tickdir','out')
        saveas(a(ii),['./clustSizes_',nhp,'.fig']);
    end
    
%     for ii = 1:numel(nhps)
%         nhp = nhps{ii};
%         b(ii) = figure(ii+10);
%         set(b(ii),'Name', ['responseOnset_',nhp,'_Distance_to_next_Cluster']); 
%         hold on; 
%         plot(histBins,nhpDistHist{ii}./sum(nhpDistHist{ii}));
%         xlabel('Distance to Next Cluster (um)')
%         ylabel('Number of Bootstrap Iterations')
%         set(gca,'FontSize',15);
%         plot(histBins,nhpDistHistObserved{ii}./sum(nhpDistHistObserved{ii}));
%         title(['Distance to Next Cluster (um)', nhp]);
%         xlabel('Distance to Next Cluster (um)')
%         ylabel('Proportion Observed')
%         legend('Boot','Observed');
%         set(gca,'FontSize',15);
%         saveas(a(ii),['./clustDists_',nhp,'.fig']);
%     end
%     
%     for ii = 1:numel(nhps)
%         nhp = nhps{ii};
%         c(ii) = figure(ii+20);
%         set(c(ii),'Name', ['responseOnset_',nhp,'_Number_of_Clusters']); 
%         hold on; 
%         plot(numHistBins,nhpNumHist{ii}./sum(nhpNumHist{ii}));
%         xlim([0 10]);
%         xlabel('Number of Clusters')
%         ylabel('Number of Bootstrap Iterations')
%         set(gca,'FontSize',15);
%         plot(numHistBins,nhpNumHistObserved{ii}./sum(nhpNumHistObserved{ii}));
%         xlim([0 10]);
%         title(['Number of Clusters__', nhp]);
%         xlabel('Number of Clusters')
%         ylabel('Proportion Observed')
%         legend('Boot','Observed');
%         set(gca,'FontSize',15);
%         saveas(a(ii),['./clustNums_',nhp,'.fig']);
% 
%     end
        d(1) = figure(1+30)
        set(d(1),'Name', ['responseOnset_AllNhps_ClusterSizes_Observed']); 
        hold on; 
        plot(histBins,allNhpSizeHist./sum(allNhpSizeHist), 'LineWidth', 2);
        set(gca,'FontSize',16);
%        xlabel('Size of Clusters (um)')
%        ylabel('Number of Bootstrap Iterations')
        plot(histBins,allNhpSizeHistObserved./sum(allNhpSizeHistObserved), 'LineWidth', 2);
%        title(['Size of Clusters__AllNhps (um)']);
%        xlabel('Size of Clusters')
%        ylabel('Proportion Observed')
        legend('Bootstrapped','Observed');
        set(gca,'tickdir','out')
        saveas(d(1),['./clustSizes_AllNhps.fig']);
%     
%         e(1) = figure(1+40)
%         set(e(1),'Name', ['responseOnset_AllNhps__Distance_to_next_Cluster']); 
%         hold on; 
%         plot(histBins,allNhpDistHist./sum(allNhpDistHist));
%         xlabel('Distance to next Cluster (um)')
%         ylabel('Number of Bootstrap Iterations')
%         set(gca,'FontSize',15);
%         plot(histBins,allNhpDistHistObserved./sum(allNhpDistHistObserved));
%         title(['Distance to next Cluster__AllNhps (um)']);
%         xlabel('Distance to next Cluster')
%         ylabel('Proportion Observed')
%         legend('Boot','Observed');
%         set(gca,'FontSize',15);
%         saveas(e(1),['./clustDists_AllNhps.fig']);
%     
%         f(1) = figure(1+50)
%         set(f(1),'Name', ['responseOnset_AllNhps_Number_of_Clusters_Observed']); 
%         hold on; 
%         plot(numHistBins,allNhpNumHist./sum(allNhpNumHist));
%         xlim([0 10]);
%         xlabel('Number of Clusters')
%         ylabel('Number of Bootstrap Iterations')
%         set(gca,'FontSize',15);
%         plot(numHistBins,allNhpNumHistObserved./sum(allNhpNumHistObserved));
%         xlim([0 10]);
%         title(['Number of Clusters__AllNhps']);
%         xlabel('Number of Clusters')
%         ylabel('Proportion Observed')
%         legend('Boot','Observed');
%         set(gca,'FontSize',15);
%         saveas(f(1),['./clustNums_AllNhps.fig']);