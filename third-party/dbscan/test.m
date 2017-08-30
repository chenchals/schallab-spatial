% From https://www.mathworks.com/matlabcentral/fileexchange/52905-dbscan-clustering-algorithm
% generate data 
N = 1e3; 
x = randn(N,1); 
x = x+linspace(0,20,N)'; 
% run algorithm 
epsilon = 10; 
MinPts = 15; 
X = [x (1:numel(x))']; 
[IDX, isnoise] = DBSCAN(X,epsilon,MinPts); 
% check results 
unique(IDX) 
unique(isnoise) 
% plot results 
clf 
PlotClusterinResult(X, IDX); 
hold on 
plot(X(isnoise,1),X(isnoise,2),'bo')
