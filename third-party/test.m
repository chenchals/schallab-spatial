% run p_burst algorithm 
close all
minSpkInBurst = 2;
spks = cell2mat(textscan(fopen('poisson-burst/SPIKE.TXT'),'%f'));
[bob,eob,sob] = p_burst(spks,min(spks),max(spks),minSpkInBurst);
% run DBSCAN algorithm 
epsilon = 10; 
minPts = minSpkInBurst; 
X = [spks (1:numel(spks))']; 
[IDX, isnoise] = DBSCAN(X,epsilon,minPts); 
% check results 
%unique(IDX) 
%unique(isnoise) 


% plot results 
figure
plotBurst(spks,bob,eob)
hold on

PlotClusterinResult(X, IDX); 
hold on 
plot(X(isnoise,1),X(isnoise,2),'ko')

% annotate
xlims = get(gca,'XLim');
ylims = get(gca,'YLim');
%
text(max(xlims)*0.1,max(ylims)*0.6,sprintf('p_burst Algorithm minSpkInBurst=%d',minSpkInBurst),'Interpreter','none')
text(max(xlims)*0.1,max(ylims)*-0.15,sprintf('DBSCAN Algorithm minPts=%d, epsilon=%d',minPts,epsilon))
set(findobj(gca,'Type','text'),'FontSize',15)

