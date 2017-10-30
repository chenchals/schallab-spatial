function [ distIms, mvFrames ] = computeDistance( sdfMat, distWindow )
%COMPUTEDISTANCE Summary of this function goes here
%   Detailed explanation goes here
 nTimes = size(sdfMat,2); % No of time points of sdfs
 nChannels = size(sdfMat,1);
 % start index of sliding window
 startInd = 1:nTimes-distWindow;
 %startInd = (0:distWindow:nTimes-distWindow)+1;
 
 distIms = arrayfun(@(x) ...
     pdist2(sdfMat(:,x:x+distWindow-1),sdfMat(:,x:x+distWindow-1),'correlation'),...
     startInd,'UniformOutput',false);
 distIms = reshape(cell2mat(distIms), nChannels, nChannels, []);
 
 maxVal = max(distIms(:)');
 minVal = min(distIms(:)');
 distIms = (distIms-minVal)./(maxVal-minVal); 
 threshold = 0.5;
 
 figure
 ax = gca;
 imagesc(distIms(:,:,1));
 ax.NextPlot = 'replaceChildren';
 axis tight manual
 zlim([0 1])
 
 colormap('cool')
 nFrames = size(distIms,3);
 mvFrames(nFrames) = struct('cdata',[],'colormap',[]);
 for ii=1:nFrames
     im = tril(distIms(:,:,ii),-1);
     im(im<threshold) = 0;
     %imagesc(im);
     %mesh(im)
     surf(im)
     titleTxt = sprintf('Time window : %d to %d',ii, ii+distWindow);
     title(titleTxt)
     drawnow
     mvFrames(ii) = getframe;
 end
 
 
 
 
 
%  maxVal = max(distIms(:)');
%  minVal = min(distIms(:)');
%  
%  colorMapName = 'jet';
%  
%  colorData = colormap(colorMapName);
%  % Int scale
%  distIms = (distIms-minVal).* ((size(colorData,1)-1)/(maxVal-minVal));
%  distIms = round(distIms)+1;
%  distIms(isnan(distIms))=1;
%  
%  for ii = 1:size(distIms,3)
%      mvFrames(ii) = im2frame(distIms(:,:,ii),colorData);
%  end

  
end

