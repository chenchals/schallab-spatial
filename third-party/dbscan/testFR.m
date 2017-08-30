% generate data 
nTrials = 200;
nLocations = 32;

% Initialize random number generator for reproducibility
rng(521,'twister');

% Values in a n-ms window per trial, for all locations
firingRates = randn(nTrials,nLocations);
% Offset the matrox to 10 hz base
firingRates = firingRates+10;

% Add random narow band of FR for some locations to simulate similarity/ same FR
% say loc 2,3,8 have similarity
rngMinMax = [15 20];
locsCorrelated = [2,3,4,16,18,20];
for ii = 1:length(locsCorrelated)
    % random narow band of FR
    randFr = (max(rngMinMax)-min(rngMinMax)).*randn(nTrials,1) + min(rngMinMax);
    firingRates(:,locsCorrelated(ii))=firingRates(:,locsCorrelated(ii))+randFr(:);
end
% Linerize the matrix
x = firingRates(:);
labels = repmat(1:nLocations,nTrials,1);
labels = labels(:);
X = [x labels]; 

% run algorithm 
epsilon = 100; 
MinPts = 100; 
[IDX, isnoise] = DBSCAN(X,epsilon,MinPts); 
% check results 
unique(IDX) 
unique(isnoise) 
% plot results 
figure()
PlotClusterinResult(X, IDX); 
hold on 
plot(X(isnoise,1),X(isnoise,2),'bo')
