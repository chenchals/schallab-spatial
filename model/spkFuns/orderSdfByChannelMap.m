function [ orderedSdfMean, orderedSdfTrials, trialOrder ] = orderSdfByChannelMap( sdfStruct, channelOrder )
%ORDERSDFBYCHANNELMAP Summary of this function goes here
%   Detailed explanation goes here
  orderedSdfMean = cell2mat({sdfStruct.sdf_mean}');
  orderedSdfMean = orderedSdfMean(channelOrder,:);
  nTrials = size(sdfStruct(1).sdf,1);
  % rows = nTrials*nChannels; cols = length(sdfWindow)
  orderedSdfTrials = cell2mat({sdfStruct.sdf}');
  % create ordering vector where
  % If there are 25 trials then
  % For channelOrder == 1 -> replace with 1:25
  % For channelOrder == 2 -> replace with 26:50
  % For channelOrder == 32 -> replace with 776:800
  trialOrder = cell2mat(arrayfun(@(x) [(x-1)*nTrials+1:x*nTrials],channelOrder,'UniformOutput',false))';
  orderedSdfTrials = orderedSdfTrials(trialOrder,:);
end


