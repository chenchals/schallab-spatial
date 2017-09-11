
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
        temp_spikes = spikeTimes(selectedTrials,cIndex);
        [ bins, rasters_full ] = getRasters(temp_spikes, alignTimes);
        if size(rasters_full,2) > 1 % there are spikes
            % Convolve & Convert to firing rate counts/ms -> spikes/sec
            sdf_full = convn(rasters_full',kernel,'same')'.*1000;
            % purne sdf and rasters to sdf window
            outNew.singleUnit(cIndex,1).sdfWindow = sdfWindow;
            outNew.singleUnit(cIndex,1).rasters = rasters_full(:,find(bins == minWin):find(bins == maxWin));        
            outNew.singleUnit(cIndex,1).sdf = sdf_full(:,find(bins == minWin):find(bins == maxWin));
            outNew.singleUnit(cIndex,1).sdf_mean = mean(outNew.singleUnit(cIndex,1).sdf);
            outNew.singleUnit(cIndex,1).sdf_std = std(outNew.singleUnit(cIndex,1).sdf);
        else            
            outNew.singleUnit(cIndex,1).sdfWindow = sdfWindow;
            outNew.singleUnit(cIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);  
            outNew.singleUnit(cIndex,1).sdf = nan(nTrials,range(sdfWindow)+1);
            outNew.singleUnit(cIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
            outNew.singleUnit(cIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
        end

        %% Old method
        Kernel.growth = 1;
        Kernel.decay = 20;
        Kernel.method = 'postsynaptic potential';
        [rasters_full, outOld.singleUnit(cIndex,1).alignmentIndex] = spike_to_raster(temp_spikes,alignTimes);
        % Modified original spike_density_function by Paul
        % added 'shape' = 'same' in call to conv
        [sdf_full, ~] = spike_density_function(rasters_full,Kernel);
        outOld.singleUnit(cIndex,1).sdfWindow = sdfWindow;
        outOld.singleUnit(cIndex,1).rasters = rasters_full(:,sdfWindow+outOld.singleUnit(cIndex,1).alignmentIndex);
        outOld.singleUnit(cIndex,1).sdf = sdf_full(:,sdfWindow+outOld.singleUnit(cIndex,1).alignmentIndex);
        outOld.singleUnit(cIndex,1).sdf_mean = mean(outOld.singleUnit(cIndex,1).sdf);
        outOld.singleUnit(cIndex,1).sdf_std = std(outOld.singleUnit(cIndex,1).sdf);
    end
    
    %% Compute for Multi Unit mu_rasters, mu_sdf, mu_sdf_mean, mu_sdf_std
    if doMultiUnit
        % Create channel numbers by parsing spikeIds
        
        % Merge units for each channel
        for cIndex = 1:maxChannels
            fprintf('Doing channel #%02d\n',cIndex);
            cellIndex = find(~cellfun(@isempty,regexp(spikeIds,num2str(cIndex,'%02d'))));
            outNew.multiUnit(cIndex,1).channelNo = cIndex;
            if numel(cellIndex)>0
                temp_spikes = arrayfun(@(x) cell2mat(spikeTimes(x,cellIndex)'),selectedTrials,'UniformOutput',false);
                [ bins, rasters_full ] = getRasters(temp_spikes, alignTimes);
                outNew.multiUnit(cIndex).spikeIds = spikeIds(cellIndex);
                outNew.multiUnit(cIndex).singleUnitIndices = cellIndex;
                if size(rasters_full,2) > 1 % there are spikes
                    % Convolve & Convert to firing rate counts/ms -> spikes/sec
                    sdf_full = convn(rasters_full',kernel,'same')'.*1000;
                    % purne sdf and rasters to sdf window
                    outNew.multiUnit(cIndex,1).sdfWindow = sdfWindow;
                    outNew.multiUnit(cIndex,1).rasters = rasters_full(:,find(bins == minWin):find(bins == maxWin));
                    outNew.multiUnit(cIndex,1).sdf = sdf_full(:,find(bins == minWin):find(bins == maxWin));
                    outNew.multiUnit(cIndex,1).sdf_mean = mean(outNew.multiUnit(cIndex,1).sdf);
                    outNew.multiUnit(cIndex,1).sdf_std = std(outNew.multiUnit(cIndex,1).sdf);
                else
                    outNew.multiUnit(cIndex,1).sdfWindow = sdfWindow;
                    outNew.multiUnit(cIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);
                    outNew.multiUnit(cIndex,1).sdf = nan(nTrials,range(sdfWindow)+1);
                    outNew.multiUnit(cIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
                    outNew.multiUnit(cIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
                end                
            else
                outNew.multiUnit(cIndex).spikeIds = {};
                outNew.multiUnit(cIndex).singleUnitIndices = [];
                outNew.multiUnit(cIndex,1).sdfWindow = sdfWindow;
                outNew.multiUnit(cIndex).rasters = nan(nTrials,range(sdfWindow)+1);
                outNew.multiUnit(cIndex,1).sdf = nan(1,range(sdfWindow)+1);
                outNew.multiUnit(cIndex,1).sdf_mean = mean(outNew.multiUnit(cIndex,1).sdf);
                outNew.multiUnit(cIndex,1).sdf_std = std(outNew.multiUnit(cIndex,1).sdf);
            end
            
        end
        
    end
    
    %plotSdfs(outNew.multiUnit,outNew.singleUnit,32,'blah');
    
    %% Plot multi-unit along with single unit SDF_mean
    figure();
    set(gcf,'Units','normalized');
    set(gcf,'PaperPosition',[0.1 0.1 0.7 0.7]);
    for cIndex = 1:maxChannels
        subplot(4,8,cIndex)
        win = outNew.multiUnit(cIndex).sdfWindow;
        mu = outNew.multiUnit(cIndex).sdf_mean;
        suIndex = outNew.multiUnit(cIndex).singleUnitIndices;
        if numel(suIndex)>0
            su = cell2mat({outNew.singleUnit(suIndex).sdf_mean}');
            plot(win,mu,'-r')
            hold on
            plot(win,su(1:end,:))
        else
            % leave empty box
        end        
    end
    
end


function [ time_bins, rasters] = getRasters(temp_spikes, alignTimes)
    alignedTimes = arrayfun(@(x,y) cell2mat(x)-y,temp_spikes,alignTimes,'UniformOutput',false);
    hMin = min(cell2mat(alignedTimes));
    hMax = max(cell2mat(alignedTimes));
    time_bins = hMin:hMax;
    rasters = cell2mat(cellfun(@(trial) histcounts(trial,hMin:hMax+1),...
        alignedTimes,'UniformOutput',false));
end