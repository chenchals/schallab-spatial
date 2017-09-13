clear all
 delete(findobj('type','figure'))
% Get file list
 d = dir('/Volumes/SchallLab/Users/Chenchal/Jacob/data/joule/*.mat');
 jouleFiles = strcat({d.folder}', filesep, {d.name}');
 
 % clear existing variable
 if exist('jp110M','var'), clear 'jp110M', end
 % Create instance of MemoryTypeModel
 jp110M = EphysModel.newEphysModel('memory',jouleFiles{11})

 % Get MultiUnitSdf
 multiSdf = jp110M.getMultiUnitSdf(jp110M.getTrialList('saccToTarget','right'), 'responseOnset',[-300 200]);

 % Plot multiUnitSdf ? as recorded
 figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8])
 for ii = 1:32 
     subplot(4,8,ii)
     plot(multiSdf(ii).sdfWindow,multiSdf(ii).sdf_mean)
     title(char(join(multiSdf(ii).spikeId,', ')))
     drawnow
 end

 % Plot multiUnitSdf ? Sorted
 channelMap = jp110M.getChannelMap();
 figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8]) 
 for ii = 1:numel(channelMap) 
     sdf = multiSdf(channelMap(ii));
     subplot(4,8,ii)
     plot(sdf.sdfWindow,sdf.sdf_mean)
     title(char(join(sdf.spikeId,', ')))
     drawnow
 end

