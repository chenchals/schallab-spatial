% https://stats.idre.ucla.edu/r/faq/how-can-i-calculate-morans-i-in-r/
% HOW CAN I CALCULATE MORAN?S I IN R? | R FAQ
% 
% Moran?s I is a measure of spatial autocorrelation?how related the values
% of a variable are based on the locations where they were measured.  Using
% functions in the ape library, we can calculate Moran?s I in R.  To
% download and load this library, enter install.packages(?ape?) and then
% library(ape).
% 
% Let?s look at an example. Our dataset, ozone, contains ozone measurements
% from thirty-two locations in the Los Angeles area aggregated over one
% month. The dataset includes the station number (Station), the latitude
% and longitude of the station (Lat and Lon), and the average of the
% highest eight hour daily averages (Av8top). This data, and other spatial
% datasets, can be downloaded from the University of Illinois? Spatial
% Analysis Lab. We can look at a summary of our location variables to see
% the range of locations under consideration.
% 
% ozone <- read.table("https://stats.idre.ucla.edu/stat/r/faq/ozone.csv", sep=",", header=T)
% head(ozone, n=10)
ozone = webread('https://stats.idre.ucla.edu/stat/r/faq/ozone.csv');
ozone(1:10,:)

% To calculate Moran?s I, we will need to generate a matrix of inverse
% distance weights.  In the matrix, entries for pairs of points that are
% close together are higher than for pairs of points that are far apart.
% For simplicity, we will treat the latitude and longitude as values on a
% plane rather than on a sphere?our locations are close together and far
% from the poles. When using latitude and longitude coordinates from more
% distant locations, it?s wise to calculate distances based on spherical
% coordinates (the geosphere package can be used).
% 
% We can first generate a distance matrix, then take inverse of the matrix
% values and replace the diagonal entries with zero:
% 
% ozone.dists <- as.matrix(dist(cbind(ozone$Lon, ozone$Lat)))
% 
% ozone.dists.inv <- 1/ozone.dists
% diag(ozone.dists.inv) <- 0
%  
% ozone.dists.inv[1:5, 1:5]
ozoneDist = 1./dist([ozone.Lon,ozone.Lat]');
for i=1:size(ozoneDist,1)
    ozoneDist(i,i) = 0;
end

% We have created a matrix where each off-diagonal entry [i, j] in the
% matrix is equal to 1/(distance between point i and point j). Note that
% this is just one of several ways in which we can calculate an inverse
% distance matrix.  This is the formulation used by Stata.  In SAS, inverse
% distance matrices have entries equal to 1/(1+ distance between point i
% and point j) and there are numerous scaling options available.
% 
% We can now calculate Moran?s I using the command Moran.I.
%Moran.I(ozone$Av8top, ozone.dists.inv)
moransI(ozone.Av8top,ozoneDist)

% Moran.I(ozone$Av8top, ozone.dists.inv)
% 
% $observed
% [1] 0.2265501
% 
% $expected
% [1] -0.03225806
% 
% $sd
% [1] 0.03431138
% 
% $p.value
% [1] 4.596323e-14






