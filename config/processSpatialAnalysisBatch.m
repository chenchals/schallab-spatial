baseDir = '/Volumes/schalllab/Users/Chenchal/clusterByLocation/processed';
%baseDir = '/Users/subravcr/temp/jacob-iMac/temp/schalllab-spatial/processed';
 flocs = @(x) strcat({x.folder}',filesep,{x.name}');
% nhpFolds = {
%     % Joule:
%     fullfile(baseDir,'joule/jp*.mat')
%     % Broca
%     fullfile(baseDir,'broca/bp*.mat')
%     % Darwin:
%     fullfile(baseDir,'darwin/2016*.mat')
%     % Darwin K:
%     %fullfile(baseDir,'darwink/Init_SetUp*.mat')
%     % Gauss:
%     fullfile(baseDir,'gauss/201*.mat')
%     % Helmholtz:
%     fullfile(baseDir,'helmholtz/201*.mat')
%     };
% nhpFiles = cellfun(@(x) flocs(dir(x)),nhpFolds,'UniformOutput',false);
% % 
% % 
% parfor jj = 1:numel(nhpFiles)
%     fl=nhpFiles{jj};
%     for ff = 1: numel(fl)
%         fileLoc = fl{ff};
%         try
%             processSpatialAnalysis0(fileLoc);
%             %processSpatialAnalysisFig(fileLoc);
%         catch me
%             fprintf('Error processing file %s\n',fileLoc);
%             disp(me)
%             continue
%         end
%     end
% end


nhpFoldsForFigs = {
    % Joule:
    fullfile(baseDir,'joule/*/moranSdfMeanZtr/*.mat')
    % Broca
    fullfile(baseDir,'broca/*/moranSdfMeanZtr/*.mat')
    fullfile(baseDir,'broca/*/moranSdfMeanZtr/*.mat')
    % Darwin:
    fullfile(baseDir,'darwin/*/moranSdfMeanZtr/*.mat')
    % Darwin K:
    fullfile(baseDir,'darwink/*/moranSdfMeanZtr/*.mat')
    % Gauss:
    fullfile(baseDir,'gauss/*/moranSdfMeanZtr/*.mat')
    % Helmholtz:
    fullfile(baseDir,'helmholtz/*/moranSdfMeanZtr/*.mat')
    };
nhpFigFiles = cellfun(@(x) flocs(dir(x)),nhpFoldsForFigs,'UniformOutput',false);

for jj = 1:numel(nhpFigFiles)
    fl=nhpFigFiles{jj};
    for ff = 1: numel(fl)
        fileLoc = fl{ff};
        try
            processSpatialAnalysisFig(fileLoc);
        catch me
            fprintf('Error processing file %s\n',fileLoc);
            disp(me)
            continue
        end
    end
end
