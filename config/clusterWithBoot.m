function [ outVar ] = clusterWithBoot( similarityVector, threshold, spacing, nBoots )
%CLUSTERWITHBOOT Summary of this function goes here
%   Detailed explanation goes here
    outVar.observed =  cluster(similarityVector, threshold, spacing);
    outVar.boots = bootstrp(nBoots, @cluster, similarityVector, threshold, spacing);
end

% use single output mode for bootstrap
function [ out ] = cluster(simVector,threshold,spacing)
  [boc,eoc,dtnc] = clusterIt(simVector, threshold);
  out.boc = boc;
  out.eoc = eoc;
  out.cSize = (eoc+1-boc).*spacing;
  out.dtnc = dtnc.*spacing;
end
