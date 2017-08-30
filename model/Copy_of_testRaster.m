
function [ outNew, outOld ] = testRaster(spikeTimes, selectedTrials, eventData, alignEventName, sdfWindow, spikeIds, maxChannels)
% load('eventData.mat')
% load('spikeData.mat')
% load('trialList.mat')
% trialsList=trialsSide;
%  Inputs:

%   63×91 cell array
%    rows  =  trials   --> 63
%    columns  =  cells --> 91
%  spiketimes([1:3,61:63],[1,2,91])
%   6×3 cell array
%                    cell_1           cell_2          cell_91    
%                 _____________    _____________    _______________
% 
%     trial_1     [11×1 double]    [38×1 double]    [ 521×1 double]
%     trial_2     [ 7×1 double]    [43×1 double]    [ 809×1 double]
%     trial_3     [ 5×1 double]    [75×1 double]    [1035×1 double]
%     trial_61    [28×1 double]    [50×1 double]    [ 622×1 double]
%     trial_62    [29×1 double]    [45×1 double]    [ 659×1 double]
%     trial_63    [ 0×1 double]    [ 0×1 double]    [   0×1 double]
% 
%  spikeTimes  =  selected trial numbers 
%
%
    doMultiUnit = 0;
    if numel(spikeIds)>0
        doMultiUnit = 1;
    end
    % BinWidth is always assumed to be 1 ms
    minWin = min(sdfWindow);
    maxWin = max(sdfWindow);
    alignTimes = eventData.(alignEventName)(selectedTrials);
    kernel = pspKernel;
    nTrials = numel(selectedTrials);

    %% New method - Compute for Single Unit: rasters, sdf, sdf_mean, sdf_std
    % Align trial-timestamps with aligntime for respective trials
    % timestamps for each trial is a column vector
    % A cell array of column vectors are timestamps of trials for a given unit
    % Example:
    nCells = size(spikeTimes,2);
    outNew = struct();
    outOld =struct();
    for cIndex = 1:nCells
        spikeTimesCell = spikeTimes(selectedTrials,cIndex);
        alignedTimes = arrayfun(@(x,y) cell2mat(x)-y,spikeTimesCell,alignTimes,'UniformOutput',false);
        hMin = min(cell2mat(alignedTimes));
        hMax = max(cell2mat(alignedTimes));
        bins = hMin:hMax;
        rasters = cell2mat(cellfun(@(trial) histcounts(trial,hMin:hMax+1),...
            alignedTimes,'UniformOutput',false));
        if size(rasters,2) > 1 % there are spikes
            % Convolve & Convert to firing rate counts/ms -> spikes/sec
            sdf = convn(rasters',kernel,'same')'.*1000;
            % purne sdf and rasters to sdf window
            outNew.singleUnit(cIndex,1).sdfWindow = sdfWindow;
            outNew.singleUnit(cIndex,1).rasters = rasters(:,find(bins == minWin):find(bins == maxWin));        
            outNew.singleUnit(cIndex,1).sdf = sdf(:,find(bins == minWin):find(bins == maxWin));
            outNew.singleUnit(cIndex,1).sdf_mean = mean(outNew.singleUnit(cIndex,1).sdf);
            outNew.singleUnit(cIndex,1).sdf_std = std(outNew.singleUnit(cIndex,1).sdf);
        else            
            outNew.singleUnit(cIndex,1).sdfWindow = sdfWindow;
            outNew.singleUnit(cIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);  
            outNew.singleUnit(cIndex,1).sdf = zeros(nTrials,range(sdfWindow)+1);
            outNew.singleUnit(cIndex,1).sdf_mean = mean(outNew.singleUnit(cIndex,1).sdf);
            outNew.singleUnit(cIndex,1).sdf_std = std(outNew.singleUnit(cIndex,1).sdf);
        end

        %% Old method
        Kernel.growth = 1;
        Kernel.decay = 20;
        Kernel.method = 'postsynaptic potential';
        [rasters, alignmentIndex] = spike_to_raster(spikeTimesCell,alignTimes);
        % Modified original spike_density_function by Paul
        % added 'shape' = 'same' in call to conv
        [sdf, ~] = spike_density_function(rasters,Kernel);
        outOld.singleUnit(cIndex,1).sdfWindow = sdfWindow;
        outOld.singleUnit(cIndex,1).rasters = rasters(:,sdfWindow+alignmentIndex);
        outOld.singleUnit(cIndex,1).sdf = sdf(:,sdfWindow+alignmentIndex);
        outOld.singleUnit(cIndex,1).sdf_mean = mean(outOld.singleUnit(cIndex,1).sdf);
        outOld.singleUnit(cIndex,1).sdf_std = std(outOld.singleUnit(cIndex,1).sdf);
    end
    
    %% Compute for Multi Unit mu_rasters, mu_sdf, mu_sdf_mean, mu_sdf_std
    if doMultiUnit
        % Create channel numbers by parsing spikeIds
        
        % Merge units for each channel
        for ch = 1:maxChannels
          cellIndex = find(~cellfun(@isempty,regexp(spikeIds,num2str(ch,'%02d'))));
          outNew.multiUnit(ch,1).channelNo = ch;
          if numel(cellIndex)>0
              rasters = outNew.singleUnit(cellIndex(1)).rasters;
              for i = 2:numel(cellIndex) % if only 1 this loop ends
                  rasters = rasters + outNew.singleUnit(cellIndex(i)).rasters;
              end
              outNew.multiUnit(ch,1).spikeIds = spikeIds(cellIndex);
              outNew.multiUnit(ch,1).sdfWindow = sdfWindow;
              outNew.multiUnit(ch,1).rasters = rasters;
              outNew.multiUnit(ch,1).sdf = convn(rasters',kernel,'same')'.*1000;
              outNew.multiUnit(ch,1).sdf_mean = mean(outNew.multiUnit(ch,1).sdf);
              outNew.multiUnit(ch,1).sdf_std = std(outNew.multiUnit(ch,1).sdf);
          else
              outNew.multiUnit(ch).spikeIds = {};
              outNew.multiUnit(ch,1).sdfWindow = sdfWindow;
              outNew.multiUnit(ch).rasters = nan(nTrials,range(sdfWindow)+1);
              outNew.multiUnit(ch,1).sdf = nan(1,range(sdfWindow)+1);
              outNew.multiUnit(ch,1).sdf_mean = mean(outNew.multiUnit(ch,1).sdf);
              outNew.multiUnit(ch,1).sdf_std = std(outNew.multiUnit(ch,1).sdf);
          end
          
        end
        
    end
end
