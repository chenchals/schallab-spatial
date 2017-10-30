function [ distIms, mvFrames ] = computeDistance( sdfMat, distWindow )
%COMPUTEDISTANCE Summary of this function goes here
%   Detailed explanation goes here
 nTimes = size(sdfMat,2); % No of time points of sdfs
 nChannels = size(sdfMat,1);
 % start index of sliding window
 startInd = 1:nTimes-distWindow;
 
 distIms = arrayfun(@(x) ...
     pdist2(sdfMat(:,x:x+distWindow-1),sdfMat(:,x:x+distWindow-1),'correlation'),...
     startInd,'UniformOutput',false);
 distIms = reshape(cell2mat(distIms), nChannels, nChannels, []);
 
 maxVal = max(distIms(:)');
 minVal = min(distIms(:)');
 
 colorMapName = 'jet';
 
 colorData = colormap(colorMapName);
 % Int scale
 distIms = (distIms-minVal).* ((size(colorData,1)-1)/(maxVal-minVal));
 distIms = round(distIms)+1;
 distIms(isnan(distIms))=1;
 
 for ii = 1:size(distIms,3)
     mvFrames(ii) = im2frame(distIms(:,:,ii),colorData);
 end

  
end

