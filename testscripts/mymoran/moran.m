function [ spAutoCorr ] = moran( features, weightMat )
%MORAN Summary of this function goes here
% All formulae are based on
% Spatial Autocorrelation (Michael F. Goodchild)
% https://alexsingleton.files.wordpress.com/2014/09/47-spatial-aurocorrelation.pdf

%
    z = features;
    w = weightMat;
    n = numel(z);
    % values must be a column vector
    z=z(:);
    [moran_i, geary_c] = computeSpatialAutocorr(z,w);
    %% Compute for hypotheses testing
    zbar = nanmean(z);
    s0 = sum(w(:));
    s1 = sum(sum((w + w').^2))/2;
    w_row_sum = sum(w,2);
    w_col_sum = sum(w,1)';
    s2 = sum((w_row_sum + w_col_sum).^2);
    % second sample moment about mean
    m2 = sum((z-zbar).^2) / n;
    % fourth sample moment about mean
    m4 = sum((z-zbar).^4) / n;
    % sample kurtosis
    b2 = m4/(m2^2);

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Expected values for index and variance
    % Resampling (N): Each of the samle (o z values) are drawn independently (n times) from a
    % population of normally distributed values of z (see ref above. p. 24)
    % ie, values of z drawn from a normal population
    % Randomization (R):  The sample (of z values) is drawn from factorial(n) possible
    % arrangements of z (see ref above. p. 24)
    % ie, sample z is one of possibe n! arrangements of z
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %% Geary Expected c _resampling_null_hypothesis
    geary_exp_c_N = 1;
    % Geary Expected c _randomization_null_hypothesis
    geary_exp_c_R = 1;
    % Geary Expected var _resampling_null_hypothesis
    geary_exp_var_N = ((2*s1 + s2)*(n-1)-4*s0^2)/(2*(n+1)*s0^2);
    % Geary Expected var _randomization_null_hypothesis
    % n^(b) = n * (n-1) * (n-2) ... * (n-b+1) (see ref above. p. 26)
    nminus2_b2 = (n-2) * ((n-2)-1) * ((n-2)-2+1);
    geary_exp_var_R = ...
         ((n-1)*s1*(n^2-(3*n)+3-(n-1)*b2) ...
        -(n-1)*s2*(n^2+3*n-6-(n^2-n+2)*b2)/4 ...
        +s0^2*(n^2-3-(n-1)^2*b2))/(n*(nminus2_b2)*s0^2);

    %% Moran expected i _resampling_null_hypothesis (N) = -1/(n-1)
    moran_exp_i_N = -1/(n-1);
    % Moran expected i _randomization_null_hypotheses (R) = -1/(n-1)
    moran_exp_i_R = -1/(n-1);
    % Moran Expected var _resampling_null_hypothesis
    moran_exp_var_N = ((n^2*s1-(n*s2)+3*s0^2)/(s0^2*(n^2-1))) - moran_exp_i_N^2;
    % Moran Expected var _randomization_null_hypothesis
    % n^(b) = n * (n-1) * (n-2) ... * (n-b+1) (see ref above. p. 26)
    nminus1_b3 = (n-1) * ((n-1)-1) * ((n-1)-2) * ((n-1)-3+1);
    moran_exp_var_R = ...
         n*((n^2-3*n+3)*s1-n*s2+3*s0^2)/(nminus1_b3*s0^2)...
        -b2*((n^2-n)*s1-2*n*s2+6*s0^2)/(nminus1_b3*s0^2)...
        -moran_exp_i_R^2;
    
    %% test statistic and alpha
    getStats = @getTestStatistic;
    [geary_z_N, geary_alpha_N, geary_sig1tail_N] = getStats(geary_c,geary_exp_c_N,geary_exp_var_N);
    [geary_z_R, geary_alpha_R, geary_sig1tail_R] = getStats(geary_c,geary_exp_c_R,geary_exp_var_R);
    [moran_z_N, moran_alpha_N, moran_sig1tail_N] = getStats(moran_i,moran_exp_i_N,moran_exp_var_N);
    [moran_z_R, moran_alpha_R, moran_sig1tail_R] = getStats(moran_i,moran_exp_i_R,moran_exp_var_R);

    %% outputs
    


  
end

function [moran_i, geary_c] = computeSpatialAutocorr(z,w)
    zbar = nanmean(z);
    % other sums...
    sum_wij = sum(w(:));% sum of all elements of weight matrix
    % Geary cij ==> z is used
    geary_cij = (repmat(z,1,n)-repmat(z',n,1)).^2; %c(i,j) = z(i)-z(j) squared
    % Geary var
    geary_var = nanvar(z);% Population Variance Z
    % Geary wij_cij
    geary_wij_cij = sum(sum(w.*geary_cij));
    % Geary Index
    geary_c = geary_wij_cij/(2*geary_var*sum_wij);
    % Moran cij  ==> z-zbar is used
    moran_cij = repmat(z-zbar,1,n).*repmat((z-zbar)',n,1); %c(i,j) = z(i)-z(j) squared
    % Moran var
    moran_var = nanvar(z,1);% Sample Variance Z
    % Geary wij_cij
    moran_wij_cij = sum(sum(w.*moran_cij));
    % Moran Index
    moran_i = moran_wij_cij/(moran_var*sum_wij);
end

