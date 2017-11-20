function [ mi ] = exploreSpatialAnalysis()
jp60 = load('/Volumes/Macintosh HD/Users/elseyjg/temp/schalllab-spatial/processed/joule/jp060n01.mat');

sess = jp60;
fNames = fieldnames(sess);
% r_squared threshold
r_sq_threshold = 0.5;
% Distance threshold
neighborDistanceStep = 100; % in microns
connectivityFx = localfunctions;
nDists = 10;

conds = {'contra_targetOnset';'contra_responseOnset';'ipsi_targetOnset';'ipsi_responseOnset'};
sessConds = fNames(contains(fNames,conds));

%for ii = 1:numel(sessConds)
ii=1;
    cond = sessConds{ii};
    sdfMeanZtr = sess.(cond).sdfMeanZtr;
    rsquared = corr(sdfMeanZtr',sdfMeanZtr').^2;
    % Since there will be n-1 crrelations, prefix 1 for self correlation
    d1 = [1; diag(rsquared,1)];
    d1Ztr = mean(sdfMeanZtr,2);
    % binarize d1
    binaryD1 = d1;
%     binaryD1(binaryD1>=r_sq_threshold) = 1;
%     binaryD1(~(binaryD1>=r_sq_threshold)) = 0;
%     
    nChannels = numel(binaryD1);
    distance = sess.info.channelSpacing*[0:nChannels-1];
    
    for dd = 1:nDists
        mi(dd).distance = distance;
        mi(dd).neighborDistance = dd*neighborDistanceStep; %every 100 microns?
        mi(dd).neighborFx = connectivityFx{1}(distance,mi(dd).neighborDistance);
        mi(dd).x = binaryD1;
        mi(dd).weightMat = getSymmetricWeightMat(mi(dd).neighborFx);
        mi(dd).moran = moransad(binaryD1,ones(numel(binaryD1),1),mi(dd).weightMat,'W','gl','n');
        clear neighborFx
    end
    
    % Plot these
end 
    
%end
% For weight matrix
% set all locations at and below threshold to 1 and rest to zero
function [ outVec ] = squareFx(distances, threshold)
  outVec = zeros(1, numel(distances));
  outVec(distances<=threshold) = 1;
end

% For weight matrix
% set a exponetial decay function for neighbor influence falls to 1/e at
% the threshold distance
function [ outVec ] = negativeExpDecay(distances, threshold)
  outVec = exp(-(distances/threshold));
end

% Create weight Matrix with neighbor function vector
function [ wMat ] = getSymmetricWeightMat(neighborFx)
  n = numel(neighborFx);
  wMat = zeros(n,n);
  for ii = 1:n
      wMat(ii,ii:n) = neighborFx(1:n-ii+1);
  end
  % Mak the matrix symmetric
  wMat = wMat' + wMat;
  % ensure diag is zero
  wMat(1:n+1:end) = 0;
end
