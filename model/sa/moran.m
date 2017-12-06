function [ moranSA ] = moran( features, weightMat, isAdjacency )
%MORAN Summary of this function goes here
% All formulae are based on
% Spatial Autocorrelation (Michael F. Goodchild)
% https://alexsingleton.files.wordpress.com/2014/09/47-spatial-aurocorrelation.pdf
% also http://www.passagesoftware.net/webhelp/Moran_s_I.htm
% http://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-spatial-autocorrelation-moran-s-i-spatial-st.htm
% also http://www.passagesoftware.net/webhelp/Local_Moran_s_I.htm
% http://pro.arcgis.com/en/pro-app/tool-reference/spatial-statistics/h-how-cluster-and-outlier-analysis-anselin-local-m.htm
%
    y = features(:);% values must be a column vector
    w = weightMat;
    moranSA = table();
    n = numel(y);
    if isAdjacency
        wij = w; %Do not row normalize, if adjacency mat
    else
        wij = w./sum(w,2);%row normalized
    end
    % http://www.passagesoftware.net/webhelp/Moran_s_I.htm
    %% Compute moran I, Global and Local
    W = sum(wij(:));
    ybar = nanmean(y);
    yi = repmat(y,1,n);% repeat y
    yj = yi';
    yminusybar = y - ybar;
    % mean second moment
    m2 = (sum(yminusybar.^2))/n;
    % mean fourth moment
    m4 = sum(yminusybar.^4)/n;

    g_moran = (n*sum(sum(wij.*(yi-ybar).*(yj-ybar))))/(W*m2*n);
    l_moran = yminusybar.*(sum(wij.*repmat(yminusybar',n,1),2)./m2);
    moranSA.I =[g_moran;l_moran];

    %% Compute expected mean and var Global
    b2 = m4/(m2^2);
    S1 = 0.5*sum(sum((wij+wij').^2));
    S2 = sum((sum(wij,2)+sum(wij,1)').^2);
    % global expected moran
    g_exp = -1/(n-1);
    % randomly permuted: global expected var
    g_var = ( ...
        (n*((n^2 - 3*n + 3)*S1 - n*S2   + 3*W^2 )...
        -b2*(      (n^2 - n)*S1 - 2*n*S2 + 6*W^2 ))...
        /((n-1)*(n-2)*(n-3)*W^2)...
        ) - (g_exp^2);
    
    %% Compute expected mean and var Local
    % local expected moran
    l_exp = -(sum(wij,2)-diag(wij))./(n-1); % E[Ii]
    % b2i
    yminusybar2 = yminusybar.^2;
    yminusybar4 = yminusybar.^4;
    b2i = (sum(yminusybar4)-yminusybar4)./((sum(yminusybar2)-yminusybar2).^2);

    % sum of squared weights, w(i,j) = 0 for all j==i
    Wij_sq = (wij.^2);
    Wi2 = sum(Wij_sq,2) - diag(Wij_sq); % sum of squared weights connected to point i
    WikWih = wij.*wij';
    WikWih(1:n+1:end) = 0;
    WikWih = sum(sum(WikWih));
    E_I2 = (((n-b2i).* Wi2)/(n-1)) - ((2*b2i-n).*WikWih)/((n-1)*(n-2));
    % E[Ii^2] - E[Ii]^2,
    l_var = E_I2 - (l_exp.^2);

    moranSA.exp_I = [g_exp;l_exp];
    moranSA.exp_var = [g_var;l_var];
    
    %% Compute z and test statistic 

    [moranSA.z,moranSA.alpha,moranSA.pval] = getTestStatistic(moranSA.I,moranSA.exp_I,moranSA.exp_var);

end

function [z,alpha,pval] = getTestStatistic(vObs, vExp, vExpVar)
    z = (vObs - vExp)./sqrt(vExpVar);
    alpha = normcdf(z);
    pval = alpha;
    % if z > 1 pval = 1-alpha
    pval(z > 1) = 1 - alpha((z > 1));
end


