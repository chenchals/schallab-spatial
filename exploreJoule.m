function [multiSdf] = exploreJoule()
    clear all
    delete(findobj('type','figure'))
    plotIt = 0;
    % Get file list
    d = dir('/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/*.mat');
    jouleFiles = strcat({d.folder}', filesep, {d.name}');

    for f = 1:numel(jouleFiles)

        fullFileName = jouleFiles{f};
        fprintf('Processing file %s\n',fullFileName);
        
        [~,fileName,~] = fileparts(fullFileName);
        % Create instance of MemoryTypeModel
        jouleModel = EphysModel.newEphysModel('memory',fullFileName);

        % Get MultiUnitSdf
        multiSdf.(fileName) = jouleModel.getMultiUnitSdf(jouleModel.getTrialList('saccToTarget','right'), 'responseOnset',[-300 200]);

        if plotIt        % Plot multiUnitSdf ? as recorded
            figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8])
            tempSdf = multiSdf.(fileName);
            for ii = 1:32
                subplot(4,8,ii)
                plot(tempSdf(ii).sdfWindow,tempSdf(ii).sdf_mean)
                title(char(join(tempSdf(ii).spikeId,', ')))
                drawnow
            end

            % Plot multiUnitSdf ? Sorted
            channelMap = jouleModel.getChannelMap();
            figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8])
            for ii = 1:numel(channelMap)
                sdf = tempSdf(channelMap(ii));
                subplot(4,8,ii)
                plot(sdf.sdfWindow,sdf.sdf_mean)
                title(char(join(sdf.spikeId,', ')))
                drawnow
            end
        end
    end
end
