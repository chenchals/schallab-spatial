function [ temp ] = jacobBootAggregate()
% setup base analysed dior
baseDir = '/Users/elseyjg/temp/schalllab-spatial/processed';
outFile = '/Users/elseyjg/temp/schalllab-spatial/processed/clustersForAllNhps.mat';
% setup all nhps for which we need to do boots
nhps ={
    'joule'
    'broca'
    'darwin'
    %'darwink' % not using as it has both mem and cap
    'helmholtz'
    'gauss'
    };
nhpFileFilters ={
    'jp*.mat'
    'bp*.mat'
    '20*.mat'
    %'darwink' % not using as it has both mem and cap
    '20*.mat'
    '20*.mat'
    };
nBoots = 1000;
threshold = 0.5;
save(outFile, 'nhps','nBoots','threshold');
temp = struct();
% for each NHP
for ii = 1:numel(nhps)
    nhp = nhps{ii};
    fileFilter = nhpFileFilters{ii};
% Get all sessions for which to do the clusterWithBoot
    fList = dir(fullfile(baseDir,nhp,fileFilter));
    for f = 1:numel(fList)
      sessFile = fullfile(fList(f).folder,fList(f).name);
      currSession = load(sessFile);
      sessionName = char([currSession.info.nhp{1} '_' regexprep(currSession.session,'-','_')]);
      fprintf('Processing session %s\n',sessionName);
      condStr = 'contra_targetOnset';
      cond = 'contra_targetOnset_right';
      if ~isfield(currSession,cond)
          cond = 'contra_targetOnset_left';
      end
      d1 = diag(currSession.(cond).rsquared,1);
      spacing = currSession.info.channelSpacing;      
% call clusterWithBoot for each session
      temp.(nhp).(sessionName).(condStr) = clusterWithBoot(d1,threshold,spacing,nBoots);
% Save boot results to file for each session
% Aggregate boots for all sessions for an NHP
% And Aggregate boots for all NHPs
    end
end
    save(outFile, '-append','-struct','temp');

% more stats....
end

