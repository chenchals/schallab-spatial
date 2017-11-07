function [ temp ] = jacobPosterAggregate()
% setup base analysed dior
inputBaseDir = 'processedJacob';
outputBaseDir = 'processedJacob/poster';
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
conditions = {'contra_targetOnset' 'contra_responseOnset'};
for c = 1:numel(conditions) % Keep conditions in separate files
    
    condStr = conditions{c};
    condRight = [condStr '_right'];
    condLeft = [condStr '_left'];
    
    outFile = fullfile(outputBaseDir, ['posterClustersAllNhps_' condStr '.mat']);
    save(outFile, 'nhps','nBoots','threshold');
    temp = struct();

    % for each NHP
    for ii = 1:numel(nhps)
        nhp = nhps{ii};
        fileFilter = nhpFileFilters{ii};
        % Get all sessions for which to do the clusterWithBoot
        fList = dir(fullfile(inputBaseDir,nhp,fileFilter));
        for f = 1:numel(fList)
            sessFile = fullfile(fList(f).folder,fList(f).name);
            currSession = load(sessFile);
            sessionName = char([currSession.info.nhp{1} '_' regexprep(currSession.session,'-','_')]);            
            
            fprintf('Processing session %s\n',sessionName);
            if isfield(currSession,condRight)
                cond = condRight;
            else
                cond = condLeft;
            end
            d1 = diag(currSession.(cond).rsquared,1);
            spacing = currSession.info.channelSpacing;
            temp.(nhp).(sessionName).info = currSession.info;
            % call clusterWithBoot for each session
            temp.(nhp).(sessionName).(condStr) = clusterWithBoot(d1,threshold,spacing,nBoots);
                      
        end
    end % for all nhps
    % Save boot results to file for each session
    % Aggregate boots for all sessions for an NHP
    % And Aggregate boots for all NHPs
    save(outFile, '-append','-struct','temp');
end % for each condition
% more stats....
end

