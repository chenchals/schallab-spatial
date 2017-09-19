% sample data from https://github.com/annoviko/pyclustering
% https://github.com/annoviko/pyclustering/tree/master/pyclustering/samples/samples
% Read sample data
samples = dir('/Users/chenchals/Projects/pyclustering/pyclustering/samples/samples/*Simple*.txt');
for s = 1: numel(samples)
    sampleFile = fullfile(samples(s).folder,samples(s).name);
    fid = fopen(sampleFile);
    nCols = numel(split(fgetl(fid)));
    fprintf('Processing file %s with cols = %d',sampleFile,nCols);
    fclose(fid);
    fid = fopen(sampleFile);
    data = cell2mat(textscan(fid, repmat('%f ',1,nCols)));
    
    X = data;
    [IDX, isnoise] = DBSCAN(X,epsilon,MinPts);
    % check results
    unique(IDX)
    unique(isnoise)
    % plot results
    clf
    PlotClusterinResult(X, IDX);
    hold on
    plot(X(isnoise,1),X(isnoise,2),'bo')
end