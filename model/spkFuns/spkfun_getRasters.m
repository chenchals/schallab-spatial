function [ time_bins, rasters] = spkfun_getRasters(spkTimes, alignTimes, varargin)
%SPKFUN_GETRASTERS Create rasters for given spike times
%   Inputs:
%     spkTimes   : spike times matrix. Rows are trials
%     alignTimes : A vector. Align time for each trial
%     varargin   : sdfWindow, rasters for the window is returned

    alignedTimes = arrayfun(@(x,y) cell2mat(x)-y,spkTimes,alignTimes,'UniformOutput',false);
    
    if numel(varargin) == 1
        sdfWin = sort(varargin{1});
        hMin = sdfWin(1);
        hMax = sdfWin(2);
    else
      hMin = round(min(cell2mat(alignedTimes)));
      hMax = round(max(cell2mat(alignedTimes)));
    end
    % any times below hMin will be binned to hMin
    % any times above hMax is binned to hMax
    time_bins = hMin:hMax;
    rasters = cell2mat(cellfun(@(trial) histcounts(trial,hMin:hMax+1),...
        alignedTimes,'UniformOutput',false));
end

