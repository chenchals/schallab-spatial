function [ boc, eoc, dtnc ] = clusterIt( similarityVector, threshold )
%CLUSTERIT Summary of this function goes here
%   Detailed explanation goes here
    doSkip = false;
    minPointsForCluster = 2;
    skipLength = 1; %always do not change
    boc = [];%#ok<*AGROW>
    eoc = [];%#ok<*AGROW>
    % distance to next cluster
    dtnc =[];%#ok<*AGROW>
    inCluster = false;
    skipOnce = false; %#ok<*NASGU>
    for ii = 1:length(similarityVector)
        if similarityVector(ii) >= threshold
            if ~inCluster
                inCluster = true;
                skipOnce = false;
                boc(length(boc)+1) = ii; 
                eoc(length(eoc)+1) = ii;
            else
                eoc(length(eoc)) = ii;
            end
        else % vec(ii)== 0 or NaN or Inf
            if doSkip
                % look ahead 1 when in cluster or flag = true
                if ii < length(similarityVector)
                    ii = ii + skipLength; %#ok<FXSET>
                    if inCluster && similarityVector(ii) >= threshold
                        eoc(length(eoc)) = ii;
                        skipOnce = true;
                    else
                        inCluster = false;
                    end
                end
            else % since the next is zero if boc(end)==eoc(end), then back off
                inCluster = false;
                if numel(boc) > 0 && (boc(end) == eoc(end))
                    boc(end) = [];
                    eoc(end) = [];                    
                end
            end
        end
    end
    % minPointsForCluster
    clustIds = find(eoc - boc + 1 >= minPointsForCluster);
    boc = boc(clustIds);
    eoc = eoc(clustIds);
    dtnc = (boc(2:end) - eoc(1:end-1)) - 1;
    dtnc(end+1) = NaN;
end

