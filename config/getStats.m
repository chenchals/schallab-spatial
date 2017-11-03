function [cStats] = getStats(nhpNames, inCellArr)
%GETSTATS Summary of this function goes here
%   Detailed explanation goes here
% Usage :

% bootSizeStats = getStats(nhpNames,nhpCSizes);

 cStats.mean = cellfun(@nanmean,inCellArr)'; 
 cStats.sd = cellfun(@nanstd,inCellArr)';
 cStats.n = cellfun(@(x) sum(~isnan(x)),inCellArr)';
 
 cStats.sem = arrayfun(@(x,y) x/sqrt(y), cStats.sd, cStats.n);
 cStats.ci = arrayfun(@(x,y) tinv(0.975,y-1)*x, cStats.sem,cStats.n);
 cStats.ciLo = arrayfun(@(x,y) x-y, cStats.mean, cStats.ci);
 cStats.ciHi = arrayfun(@(x,y) x+y, cStats.mean, cStats.ci);
 
 cStats = struct2table(cStats);
 cStats.Properties.RowNames = nhpNames;
 
end


