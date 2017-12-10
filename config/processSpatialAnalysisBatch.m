baseDir = '/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed';
flocs = @(x) strcat({x.folder}',filesep,{x.name}');

nhpFolds = {
    % Joule:
    fullfile(baseDir,'joule/MEM/*.mat')
    % Broca
    fullfile(baseDir,'broca/DEL/*.mat')
    fullfile(baseDir,'broca/MEM/*.mat')
    % Darwin:
    fullfile(baseDir,'darwin/MEM/*.mat')
    % Darwin K:
    fullfile(baseDir,'darwink/MG/*.mat')
    % Gauss:
    fullfile(baseDir,'gauss/MEM/*.mat')
    % Helmholtz:
    fullfile(baseDir,'helmholtz/MEM/*.mat')
    };
nhpFiles = cellfun(@(x) flocs(dir(x)),nhpFolds,'UniformOutput',false);

for jj = 1:numel(nhpFiles)
    fl=nhpFiles{jj};
    for ff = 1: numel(fl)
        fileLoc = ff{ff};
        try
            processSpatialAnalysis(fileLoc);
        catch me
            fprintf('Error processing file %s\n',fileLoc);
            disp(me)
            continue
        end
    end
end


