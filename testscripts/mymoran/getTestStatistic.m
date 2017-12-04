function [z,alpha,sig1tail] = getTestStatistic(vObs, vExp, vExpVar)
%GETTESTSTATISTIC Summary of this function goes here
%   Detailed explanation goes here
  z = (vObs - vExp)/sqrt(vExpVar);
  alpha = normcdf(z);
  sig1tail = alpha;
  if z >1
      sig1tail = 1 -alpha;
  end
end
