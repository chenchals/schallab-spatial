function [ time_bins, rasters] = spkfun_getRasters(temp_spikes, alignTimes)
%SPKFUN_GETRASTERS Summary of this function goes here
%   Detailed explanation goes here
    alignedTimes = arrayfun(@(x,y) cell2mat(x)-y,temp_spikes,alignTimes,'UniformOutput',false);
    hMin = round(min(cell2mat(alignedTimes)));
    hMax = round(max(cell2mat(alignedTimes)));
    time_bins = hMin:hMax;
    rasters = cell2mat(cellfun(@(trial) histcounts(trial,hMin:hMax+1),...
        alignedTimes,'UniformOutput',false));
end

