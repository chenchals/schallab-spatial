function [ mI ] = myMoran( y, w )
%MYMORAN Summary of this function goes here
% All formulae are based on
% Spatial Autocorrelation (Michael F. Goodchild)
% https://alexsingleton.files.wordpress.com/2014/09/47-spatial-aurocorrelation.pdf

    n = length(y);
    %% Compute Morans I (no optimization)
    ybar = nanmean(y);
    denom = 0; % sum of squared deviations of x
    numer = 0; % is similarity
    % non vectorized
    for ii =1:n
        xiMinusXbar = y(ii) - ybar;
        denom = denom + xiMinusXbar^2;
        for jj = 1:n
            if jj==ii
                continue
            end
            numer = numer + w(ii,jj)*xiMinusXbar*(y(jj)-ybar);
        end
    end
    S0 = sum(w(:)); % sum of weights
    mI.I = (n/S0)*numer/denom;
    
    %% Compute Estimated I
    mI.estimated_I = -1/(n-1);
    
    %% Compute Variance
    % S0 sum of weights
    % Conact values of weights by columns
    % Conact values of weights by rows
    % S1 (no optimization...)
    wt= transpose(w); %for ij access
    S1 = 0.5*sum((wt(:) + w(:)).^2);
    % S2 
    rowsum = sum(w,2);
    colsum = sum(w,1);
    S2 = sum((rowsum(:) + colsum(:)).^2);
    S3 = ((1/n) * sum( (y-ybar).^4)) / ...
        ((1/n) * sum( (y-ybar).^2)).^2;
    S4 = (n^2 - 3*n +3)*S1 - n*S2 + 3*S0;
    S5 = (n^2 -n)*S1 - 2*n*S2 + 6*S0^3;
    mI.var_I = (n*S4 - S3*S5)/((n-1)*(n-2)*(n-3)*S0^2);
    
    
end

