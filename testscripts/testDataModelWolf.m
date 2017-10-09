  %% Check DataModelWolf
  srcFolder = '.';
  
  matPath ='/Volumes/schalllab/Users/Wolf/ephys_db/Darwin/2016-03-11a/DSP/DSP*/*MG*.mat';
  nhpTable.matPath = {matPath};
  allSessions=cellfun(@(x) dir(fullfile(srcFolder,x)),nhpTable.matPath,'UniformOutput',false);
  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);
  sessions = sessions(~cellfun(@isempty,sessions));   
  
  session = sessions{1}; chMap=[1:16];
  %chMap =[1, 2, 3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]';
  
  D=DataModel.newInstance(DataModel.WOLF_DATA_MODEL,session,chMap);
  
  evData = D.getEventData;
  
  
  spkData = D.getSpikeData;
  
  
  %% spiketimes to cellArray
  DSP02b=load('data/Users/Wolf/ephys_db/Darwin/2016-02-16a/DSP/DSP02b/2016-02-16a_DSP02b_MG_a.mat');
  key = 'spikeTimes';
  var = 'spiketimes';

  temp.(var)=DSP02b.(var);
  nTrials = size(temp.(var),1);

for f=1:2
    if f==2
        temp.(var)(1,:)=nan(1,length(temp.(var)(1,:)));
    end
    for t = 1:nTrials
        spikeData.(var){t,f}=temp.(var)(t,~isnan(temp.(var)(t,:)))';
    end
    spikeData2.(var){:,f} = arrayfun(@(t) temp.(var)(t,~isnan(temp.(var)(t,:)))',1:nTrials,'UniformOutput',false);
end