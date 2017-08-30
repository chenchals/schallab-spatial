% Test MemoryTypeModel 
monk = 'joule';%'broca';%'joule'
d = dir(['/Volumes/schalllab/Users/Chenchal/Jacob/data/',monk,'/*121n01.mat']);
dataSources = strcat({d.folder},filesep,{d.name})';

for jj= 1:numel(dataSources)
    try
    dataSource = dataSources{jj};
    
    eventVars= {...
        'fixWindowEntered',...
        'targOn',...
        'responseCueOn',...
        'responseOnset',...
        'toneOn',...
        'rewardOn',...
        'trialOutcome',...
        'saccToTargIndex',...
        'targAngle',...
        'saccAngle'
        };
    
    spikeIdvar='SessionData.spikeUnitArray';
    spiketimeVar= 'spikeData';
    channelMap= [9:16,25:32,17:24,1:8];
    
    m=EphysModel.newEphysModel('memory',dataSource);
    data(jj).dataSource = dataSource;
    disp(data(jj).dataSource);
    % Load event data
    data(jj).events = m.getEventData(eventVars);
    
    % Load spike data into convienient type
    data(jj).spikes = m.getSpikeData('spikeIdVar',spikeIdvar, 'spiketimeVar', spiketimeVar, 'channelMap', channelMap);
    
    % Create SDFs
    
    catch ME
        disp(dataSource)
        disp(ME)
    end
    
end
