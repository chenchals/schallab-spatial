% See: https://cran.r-project.org/web/packages/ape/vignettes/MoranI.pdf
%Moran?s autocorrelation coefficient (often denoted as I) is an extension of Pearson
%product-moment correlation coefficient to a univariate series [2, 5].
%Recall that Pearson?s correlation (denoted as ?) between two variables x and y both of length n is:
% ? =
Xn
i=1
(xi ? x¯)(yi ? y¯)
"Xn
i=1
(xi ? x¯)
2Xn
i=1
(yi ? y¯)
2
#1/2
,
where ¯x and ¯y are the sample means of both variables. ? measures whether, on
average, xi and yi are associated. For a single variable, say x, I will measure
whether xi and xj , with i 6= j, are associated. Note that with ?, xi and xj are
not associated since the pairs (xi
, yi) are assumed to be independent of each
other.
In the study of spatial patterns and processes, we may logically expect that
close observations are more likely to be similar than those far apart. It is usual
to associate a weight to each pair (xi
, xj ) which quantifies this [3]. In its simplest
form, these weights will take values 1 for close neighbours, and 0 otherwise. We
also set wii = 0. These weights are sometimes referred to as a neighbouring
function.
I?s formula is:

n = length(d1);
% Neighbor function: How does the associationof neighboring points decay?
% assume some exponential
neighborFx = @(lam,x) exp(-(x.*lam));
decayFx = neighborFx(0:n-1,0.5); % 
% create weight matrix
w = zeros(n,n); 
for ii=1:18 
    fill = decayFx(1:end-ii+1); 
    w(ii,ii:end) = fill; 
    w(ii:end,ii) = fill;
end

