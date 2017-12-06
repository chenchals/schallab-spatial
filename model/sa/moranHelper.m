function [ outFx, weightMat ] = moranHelper( distanceVec, distanceThreshold, functionForm )
%MORANHELPER Summary of this function goes here
%   Detailed explanation goes here
  switch functionForm
      case 'square'
          neighborFx = squareFx(distanceVec, distanceThreshold);
      case 'decay'
          neighborFx = expDecayFx(distanceVec, distanceThreshold);
      otherwise
              error('functionForm must be one of [''%s'' | ''%s'']\n','square','decay')
  end
  weightMat = computeWeightMatrix(neighborFx);
  outFx = [distanceVec(:) neighborFx(:)];

end
% set all locations at and below threshold to 1 and rest to zero
function [ fx ] = squareFx(distances, threshold)
    fx = zeros(numel(distances),1);
    fx(fx<=threshold) = 1;
    
end

% For weight matrix
% set a exponetial decay function for neighbor influence falls to 1/e at
% the threshold distance
function [ fx ] = expDecayFx(distances, threshold)
    fx = exp(-(distances/threshold));
end

% Create weight Matrix with neighbor function vector
function [ wMat ] = computeWeightMatrix(neighborFxVector)
    n = numel(neighborFxVector);
    wMat = zeros(n,n);
    for ii = 1:n
        wMat(ii,ii:n) = neighborFxVector(1:n-ii+1);
    end
    % Make the matrix symmetric
    wMat = wMat' + wMat;
    % ensure diag is zero
    wMat(1:n+1:end) = 0;
end


