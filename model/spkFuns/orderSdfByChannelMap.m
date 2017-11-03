function [ sdfOrdered ] = orderSdfByChannelMap( sdfStruct, channelOrder )
%ORDERSDFBYCHANNELMAP Summary of this function goes here
%   Detailed explanation goes here
  
    % Validate
    assert(size(sdfStruct,1) == numel(channelOrder),...
        sprintf(['Ordering single-unit Sdfs by channelMap is not yet implemented.\n'...
        'Use only for multi-unit sdfs.\n Number of units [%d] in sdf_mean '...
        'must equal number of channels [%d] in channelOrder'],...
        size(sdfStruct,1), numel(channelOrder)));
    % the channel Order must be numbers form 1 to n.  So if we have channel
    % order as 33,34,35,...64 -> these need to be offset to -32 effectively
    % making them 1-32 (This is the case for recording with 2 probes
    channelOffset = 0;
    if min(channelOrder) > 1
        channelOffset = min(channelOrder) - 1;
    end
    channelOrder = channelOrder - channelOffset;
    
    %% For multi-unit mean sdfs
    sdfOrdered.channelMap = channelOrder(:);
    sdfOrdered.sdfMean = cell2mat({sdfStruct.sdfMean}');
    sdfOrdered.sdfMean = sdfOrdered.sdfMean(channelOrder,:);
    
    sdfOrdered.spikeIds = {sdfStruct(channelOrder).spikeIds}';
    sdfOrdered.sdfWindow = sdfStruct(1).sdfWindow;
    sdfOrdered.nTrials = sdfStruct(1).nTrials;
    sdfOrdered.selectedTrials = sdfStruct(1).selectedTrials;
    
    %% For multi-unit trial sdfs
    sdfOrdered.sdf = arrayfun(@(x) sdfStruct(x).sdf,channelOrder,'UniformOutput',false);;
    
    
end


