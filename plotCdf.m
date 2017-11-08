boo100 = table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_H_C_TargOn_BOO_100'));
obs100 = table2array(readtable('posterClusterDistribution.xlsx','Sheet','size_H_C_TargOn_OBS_100'));
boo100(:,3)=cumsum(boo100(:,2))/sum(boo100(:,2));
obs100(:,3)=cumsum(obs100(:,2))/sum(obs100(:,2));

hold on;
cdfplot(boo100(:,3));
cdfplot(obs100(:,3));

obsObs = [];
for i = 1:size(obs100,1)
    obsObs = cat(1,obsObs,ones(obs100(i,2),1).*obs100(i,1));
end

bootObs = [];
for i = 1:size(obs100,1)
    bootObs = cat(1,bootObs,ones(boo100(i,2),1).*boo100(i,1));
end

