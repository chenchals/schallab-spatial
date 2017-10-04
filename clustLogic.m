function [ out ] = clustLogic( similarityVector, threshold )
% similarityVector is a column vector
%CLUSTLOGIC Summary of this function goes here
%   Detailed explanation goes here
% clusters.space = clustersSpace
% get r^2 for only pairs of neighboring channels

% Threshold it here
% That is pass any vector not necessarily 0s and 1s
% add argument threshold
% convert vector to thresholded values
% threshold = .5;
thresholdedVector = similarityVector;
thresholdedVector(thresholdedVector < threshold) = 0; % changed from nan to 0 for logical indexing 8/25 meeting
thresholdedVector(thresholdedVector >= threshold) = 1;

% Define number of columns to average - what is the meaning, neighboring
% elements?
AVG_COLS = 3;
% what is the divided by 3 mean
r_norm = thresholdedVector'/3;
% How do you get/compute this threshold
threshold = 1.666; % computeThreshold(.....)

% Find the values that determine possibility of clustering
rLeft = thresholdedVector';
rCenter = thresholdedVector';
rRight = fliplr(thresholdedVector');
% Dimension over which to average
DIM = 2; % Columns
% Use filter to calculate the moving average across EVERY combination of columns
r_moving_avgLeft = filter(ones(1,AVG_COLS)/AVG_COLS,1,rLeft,[],DIM);
r_moving_avgCenter = movmean(rCenter, 3, 'Endpoints', 0);
r_moving_avgRight = filter(ones(1,AVG_COLS)/AVG_COLS,1,rRight,[],DIM);
r_moving_avgRight = fliplr(r_moving_avgRight);

r_moving_sum = r_moving_avgLeft + r_moving_avgCenter + r_moving_avgRight + r_norm;
r_moving_sum(r_moving_sum < threshold) = 0; % changed from nan to 0 for logical indexing 8/25 meeting
r_moving_sum(r_moving_sum >= threshold) = 1;

% Measure lengths of stretches of 1's.

cluster_lengths = regionprops(logical(r_moving_sum), 'Area');
% Convert from structure to simple array of lengths.
cluster_lengths_array = [cluster_lengths.Area];
% If you want 0's in between for spatial purposes:
out = zeros(1, 2*length(cluster_lengths_array)+1);
out(2:2:end) = cluster_lengths_array;


end

