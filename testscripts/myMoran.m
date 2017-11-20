function [ spAutoCorr ] = myMoran( features, weightMat )
%MYMORAN Summary of this function goes here
% All formulae are based on
% Spatial Autocorrelation (Michael F. Goodchild)
% https://alexsingleton.files.wordpress.com/2014/09/47-spatial-aurocorrelation.pdf
%    Inputs:
%       features : A column vector of feature of interest. In general Each
%       row corresponds to all attributes (measured features) for a spatial
%       object, taken one attribute of interest at a time. Each feature
%       value is denoted by z. There are zn values for n spatial objects.
%
%       weightMat: A matrix of dependence of feature on spatial location.
%       If there are 32 spatial *point* objects, then each row is a vector
%       of the neighbor function or contiguity values. This determines
%       how much does feature at one spatial location influences features
%       at neighbor spatial locations.

%% Definitions:
% Spatial autocorrelation is a comparision of two types of information:
% (a) Similarity among attributes (measured features)
%  Categories(3): interval data, ordinal data, and nominal data
% (b) Similarity of location (spatial objects)
%  Categories(4): points, lines, areas, & lattice)
% For current purpose our 
%   spatial objects are *points*: channel location
%   attribute objects are *interval* data: firing rates, counts 
  x_i = features;
  n = size(x_i,1);% nunmer of objects in sample
  x_bar = sum(x_i)/n;
  % i,j are any two objects (spatial points), i not= j
  % x_i is value of feature at ith location
  % w_ij = similarity of i's and j's location, w_ii = 0 for all i
  % w_ij is set to some suitable decreasing function, Example: 
  % w_ij = (distance_ij)^(-b) or exp(-b*distance_ij)
  %  b interpreted as rate at which the weight (influence) decreases over
  %  distance.
  w_ij = weightMat; % diag(weightMat,0) must equal 0
  % Row normalize = sum of a row must be 1
  w_ij = w_ij./sum(w_ij,2);
  
  sum_w_ij = sum(w_ij(:));
  % c_ij = similarity of i's and j's attributes
  % In general this is the covariance between the value of a feature at one
  % place and its value at another
  % for morans
  [c_ij_m, s_sq_m] = getFeatureSpatialCovariance(x_i, 'moran');
  % for geary
  [c_ij_g, s_sq_g] = getFeatureSpatialCovariance(x_i, 'geary');
  % compute coeffs:
  spAutoCorr.moran.index(1) = sum(sum(w_ij.*c_ij_m))/(s_sq_m * sum_w_ij)
  spAutoCorr.geary.index(1) = sum(sum(w_ij.*c_ij_g))/(2 * s_sq_g * sum_w_ij)
  spAutoCorr.moran
  spAutoCorr.geary
  
  % Local Moran I
  % I_i = z_i * sum_over_j(w_ij * z_j)
  % z_i = (x_i-x_bar) / SD
  z_i = (x_i-x_bar)/sqrt(s_sq_m);
  
  for i = 1:n
      j = 1:n;
      j = j(j~=i);
      spAutoCorr.moran.index(i+1,1) = sum(w_ij(i,j)'.*z_i(j));
  end
  

end

function [c_ij, s_square] = getFeatureSpatialCovariance(z, varargin)
  % c_ij = similarity of i's and j's attributes 
  % computation of c_ij depends on the *type* of attributes
  %   interval data: Commonly used are
  %       squared diff (z_i-z_j)^2 and 
  %        the product (z_i-z_bar)*(z_j-z_bar)
  %   nominal data: checker board
  %       c_ij = 1 if z_i == z_j, i.e. have same attribute values
  %       c_ij = 0 if z_i ~= z_j, i.e. have different attribute values
  %   ordinal data: Compare ranks of z_i and z_j ...
  % In general this is the covariance between the value of a feature at one
  % place and its value at another
  if numel(varargin) == 1
      indexType = varargin{1};
  else
      indexType = 'moran';
  end
  z_sub_z_bar = z - nanmean(z);
  % c_ij
  if islogical(z) % feature type: Nominal
      c_ij = double(z)*double(z');
  else % feature Type: Interval
      switch indexType
          case 'moran'
              c_ij = z_sub_z_bar * z_sub_z_bar';
          case 'geary'
              c_ij = zeros(numel(z),numel(z));
              for i = 1:numel(z)
                  v = (z - z(i)).^2;
                  c_ij(i,1:length(v)) = v;
                  c_ij(1:length(v),i) = v;
              end
      end
  end
  % s_square : geary sigma_sq or moran s_sq  
  switch indexType
      case 'moran'
          s_square = nansum(z_sub_z_bar.^2)/numel(z);
      case 'geary'
          s_square = nansum(z_sub_z_bar.^2)/(numel(z)-1);
  end

end
  

