function [ outNew, Z, fxHandles ] = spkfun_sdf(spikeTimes, selectedTrials, eventData, alignEventName, sdfWindow, spikeIds, maxChannels)
%SDF Summary of this function goes here
%   Detailed explanation goes here
%
%  Inputs: 
%    spikeTimes: Cell array of spiketimes {nTrials x nCells cell}.
%                    cell_1           cell_2          cell_91    
%                 _____________    _____________    _______________
% 
%     trial_1     [11�1 double]    [38�1 double]    [ 521�1 double]
%     trial_2     [ 7�1 double]    [43�1 double]    [ 809�1 double]
%     trial_3     [ 5�1 double]    [75�1 double]    [1035�1 double]
%     trial_61    [28�1 double]    [50�1 double]    [ 622�1 double]
%     trial_62    [29�1 double]    [45�1 double]    [ 659�1 double]
%     trial_63    [ 0�1 double]    [ 0�1 double]    [   0�1 double]
% 
%    selectedTrials: A vector if trialNos.
%
%    eventData: A structure where fields are eventNames.
%               A field is a vector of timestamps [nTrials x 1 double].
%               or
%               A field is a cell array of strings {nTrials x 1 cell}.
%
%    alignEventName: A char. Event to align spike timestamps. 
%                    Event name must be a fieldname of eventData structure.
%
%    sdfWindow: A 2 element vector [minTime maxTime] for computing sdf.
%
%    spikeIds: A cell array of strings. 
%              The number of elements must equal size(spikeTimes,2).
%              The 1st element of spikeIds is the Spiking Unit ID for the
%              1st column in the spikeTimes cell array.
%
%    maxChannels: A scalar. Specifies maximum channel number of the probe.
%                 
%

%% Input Validation
    assert(iscell(spikeTimes),... %if 0
        sprintf('Argument spikeTimes must be a cell array {nTrials x nCells cell} of spikeTimes, but was %s',class(spikeTimes)));
    
    assert(~iscell(selectedTrials) | ~isempty(selectedTrials),... %if 0
        sprintf('Argument selectedTrials must be a vector of trialNos [nTrialsx1 double], but was %s',class(selectedTrials)));

    assert(isstruct(eventData),... % if 0
        sprintf('Argument eventData must be a struct, with each field of [nTrialsx1 double] or {nTrialsx1 cell}, but was %s',class(eventData)));

    assert(ischar(alignEventName),... %if 0
        sprintf('Argument alignEventName must be a char, but was %s',class(alignEventName)));

    assert(numel(sdfWindow) == 2,... %if 0
        sprintf('Argument sdfWindow must be a 2 element vector, but had %d elements',numel(sdfWindow)));

    assert(iscellstr(spikeIds),... %if 0
        sprintf('Argument spikeIds must be a cell array of Strings {nCells x 1 cell} of spike unit Ids, but was %s',class(spikeIds)));
    
    assert(isscalar(maxChannels),... %if 0
        sprintf('Argument maxChannels must be a scalar, but was %s',class(maxChannels)));
    
    % Ensure trials are valid
    verifyCategories(alignEventName,fieldnames(eventData));
    
    % Check (a) Number of selected trials is > 0  and (b) maximum trial
    % number of selected trials can be intexed into spikeTime cell array
    assert(numel(selectedTrials)>0 && max(selectedTrials)<=size(spikeTimes,1),...
        sprintf('Number of selected trials must be more than 0, but was %d.\nMaximum trial number %d exceeds %d trials in spikeTimes.',...
        numel(selectedTrials),max(selectedTrials),size(spikeTimes,1)));
    
    % Check no of cell Ids = number of columns on spikeTimes Cell array
     assert(numel(spikeIds)==size(spikeTimes,2),...
         sprintf('Number of spike Ids %d do not match number of columns %d in spikeTimes cell array.',numel(spikeIds),size(spikeTimes,1)));
     
     
%% Compute re-useables for this call
    sdfWindow = sort(sdfWindow);
    % BinWidth is always assumed to be 1 ms
    minWin = min(sdfWindow);
    maxWin = max(sdfWindow);
    sdfWindow = (minWin:maxWin)';
    alignTimes = eventData.(alignEventName)(selectedTrials);
    kernel = pspKernel;
    nTrials = numel(selectedTrials);

    %% Compute for Single Unit: rasters, sdf, sdf_mean, sdf_std
    nCells = size(spikeTimes,2);
    outNew = struct();
    for chanIndex = 1:nCells
        temp_spikes = spikeTimes(selectedTrials,chanIndex);
        spikeId = spikeIds(chanIndex);
        Z.singleUnit(chanIndex,1).spikeId = spikeId;
        [ bins, rasters_full ] = spkfun_getRasters(temp_spikes, alignTimes);
        if size(rasters_full,2) > 1 % there are spikes
            outNew.singleUnit(chanIndex,1) = computeSdfs(rasters_full,bins,kernel,minWin,maxWin,spikeId);
            % Convolve & Convert to firing rate counts/ms -> spikes/sec
            sdf_full = convn(rasters_full',kernel,'same')'.*1000;
            % purne sdf and rasters to sdf window            
            Z.singleUnit(chanIndex,1).sdfWindow = sdfWindow;
            Z.singleUnit(chanIndex,1).rasters = rasters_full(:,find(bins == minWin):find(bins == maxWin));        
            Z.singleUnit(chanIndex,1).sdf = sdf_full(:,find(bins == minWin):find(bins == maxWin));
            Z.singleUnit(chanIndex,1).sdf_mean = mean(Z.singleUnit(chanIndex,1).sdf);
            Z.singleUnit(chanIndex,1).sdf_std = std(Z.singleUnit(chanIndex,1).sdf);
        else  
            outNew.singleUnit(chanIndex,1) = computeSdfNans(nTrials,minWin,maxWin,spikeId);
            Z.singleUnit(chanIndex,1).sdfWindow = sdfWindow;
            Z.singleUnit(chanIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);  
            Z.singleUnit(chanIndex,1).sdf = nan(nTrials,range(sdfWindow)+1);
            Z.singleUnit(chanIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
            Z.singleUnit(chanIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
        end
    end
    
    %% Compute for Multi Unit: rasters, sdf, sdf_mean, sdf_std
    % Merge units for each channel
    for chanIndex = 1:maxChannels
        fprintf('Doing channel #%02d\n',chanIndex);
        cellIndex = find(~cellfun(@isempty,regexp(spikeIds,num2str(chanIndex,'%02d'))));
        Z.multiUnit(chanIndex,1).channelNo = chanIndex;
        if numel(cellIndex)>0
            temp_spikes = arrayfun(@(x) cell2mat(spikeTimes(x,cellIndex)'),selectedTrials,'UniformOutput',false);
            [ bins, rasters_full ] = spkfun_getRasters(temp_spikes, alignTimes);
            spikeId = spikeIds(cellIndex);
            Z.multiUnit(chanIndex).spikeId = spikeId;
            Z.multiUnit(chanIndex).singleUnitIndices = cellIndex;
            if size(rasters_full,2) > 1 % there are spikes
               outNew.multiUnit(chanIndex,1) = computeSdfs(rasters_full,bins,kernel,minWin,maxWin,spikeId,cellIndex,chanIndex);
                % Convolve & Convert to firing rate counts/ms -> spikes/sec
                sdf_full = convn(rasters_full',kernel,'same')'.*1000;
                % purne sdf and rasters to sdf window
                Z.multiUnit(chanIndex,1).sdfWindow = sdfWindow;
                Z.multiUnit(chanIndex,1).rasters = rasters_full(:,find(bins == minWin):find(bins == maxWin));
                Z.multiUnit(chanIndex,1).sdf = sdf_full(:,find(bins == minWin):find(bins == maxWin));
                Z.multiUnit(chanIndex,1).sdf_mean = mean(Z.multiUnit(chanIndex,1).sdf);
                Z.multiUnit(chanIndex,1).sdf_std = std(Z.multiUnit(chanIndex,1).sdf);
            else
                outNew.multiUnit(chanIndex,1) = computeSdfNans(nTrials,minWin,maxWin,spikeId,cellIndex,chanIndex);
                Z.multiUnit(chanIndex,1).sdfWindow = sdfWindow;
                Z.multiUnit(chanIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);
                Z.multiUnit(chanIndex,1).sdf = nan(nTrials,range(sdfWindow)+1);
                Z.multiUnit(chanIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
                Z.multiUnit(chanIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
            end
        else
            Z.multiUnit(chanIndex).spikeId = {};
            Z.multiUnit(chanIndex).singleUnitIndices = [];
            outNew.multiUnit(chanIndex,1) = computeSdfNans(nTrials,minWin,maxWin,{},[],[]);
            Z.multiUnit(chanIndex).spikeIds = {};
            Z.multiUnit(chanIndex).singleUnitIndices = [];
            Z.multiUnit(chanIndex,1).sdfWindow = sdfWindow;
            Z.multiUnit(chanIndex).rasters = nan(nTrials,range(sdfWindow)+1);
            Z.multiUnit(chanIndex,1).sdf = nan(1,range(sdfWindow)+1);
            Z.multiUnit(chanIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
            Z.multiUnit(chanIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
        end
        
    end

    fxHandles = asMatHandles();
end


function [ oStruct ] = computeSdfs(rasters,bins,kernel,minWin,maxWin,spikeId,varargin)
            sdfWindow = (minWin:maxWin)';
            % Convolve & Convert to firing rate counts/ms -> spikes/sec
            sdf_full = convn(rasters',kernel,'same')'.*1000;
            % purne sdf and rasters to sdf window            
            oStruct.spikeId = spikeId;
            if numel(varargin) == 2
                oStruct.singleUnitIndices = varargin{1};
                oStruct.channelIndex = varargin{2};
            end
            oStruct.sdfWindow = sdfWindow;
            oStruct.rasters = rasters(:,find(bins == minWin):find(bins == maxWin));        
            oStruct.sdf = sdf_full(:,find(bins == minWin):find(bins == maxWin));
            oStruct.sdf_mean = mean(oStruct.sdf);
            oStruct.sdf_std = std(oStruct.sdf);
end

function [ oStruct ] = computeSdfNans(nTrials,minWin,maxWin,spikeId,varargin)
            sdfWindow = (minWin:maxWin)';
            oStruct.spikeId = spikeId;
            if numel(varargin) == 2
                oStruct.singleUnitIndices = varargin{1};
                oStruct.channelIndex = varargin{2};
            end
            oStruct.singleUnit(chanIndex,1).sdfWindow = sdfWindow;
            oStruct.singleUnit(chanIndex,1).rasters = nan(nTrials,range(sdfWindow)+1);  
            oStruct.singleUnit(chanIndex,1).sdf = nan(nTrials,range(sdfWindow)+1);
            oStruct.singleUnit(chanIndex,1).sdf_mean = nan(1,range(sdfWindow)+1);
            oStruct.singleUnit(chanIndex,1).sdf_std = nan(1,range(sdfWindow)+1);
end


function [ fxHandles ] = asMatHandles()
   fxHandles.sdf_mean=@(x) cell2mat(transpose({x.sdf_mean}));
end



