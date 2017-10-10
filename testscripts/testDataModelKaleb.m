  %% Check DataModelKaleb
  % has 1-64
  % Init_SetUp-160713-144841
  srcFolder = '';
  matPath = '/Volumes/schalllab/Users/Kaleb/dataProcessed/Init_SetUp-160715-150111/Channel*/chan*.mat'
       
  nhpTable.matPath = {matPath};
  nhpTable.ephysChannelMap = {(1:32)'};
  %nhpTable.ephysChannelMap = {(33:64)'};
  allSessions=cellfun(@(x) dir(fullfile(srcFolder,x)),nhpTable.matPath,'UniformOutput',false);
  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);
  
  
  % Filter:
   outSessions = cell(size(sessions,1),1);
    for s = 1:numel(sessions)
        if isempty(sessions{s})
            continue
        end    
    channelStr = arrayfun(@(x) ['Channel', num2str(x,'%d'),'/chan'],nhpTable.ephysChannelMap{s},'UniformOutput',false)';
    matched = regexp(sessions{s},char(join(channelStr,'|')),'match');
    outSessions{s} = sessions{s}(find(cellfun(@(x) numel(x),matched)>0)); %#ok<FNDSB>
    end
%   
  % order the spikeUnit files by channel number
  for i = 1:numel(outSessions)
    sessionO = regexprep(outSessions{i},'/Channel(\d)/','/Channel0$1/');
    sessionO = sortrows(sessionO);
    outSessions{i} = regexprep(sessionO,'/Channel0(\d)/','/Channel$1/');
  end
  
  sessions = outSessions;
  session = sessions{1}; chMap=nhpTable.ephysChannelMap{1};
  %chMap =[1, 2, 3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]';
  
  model=DataModel.newInstance(DataModel.KALEB_DATA_MODEL,session,chMap);
  
  % for event data
  % get the behavior file location
  %f = fullfile(char(cellfun(@char,regexp(f,'^(.*-\d*)/.*','tokens'),'UniformOutput',false)),'Behav.mat');
  
  evData = model.getEventData;
  
  spkData = model.getSpikeData;
  
  % SDF
  % 2017-10-10 13:23:01.492|INFO|processSessions|Doing condition: outcome right, alignOn targetOnset, sdfWindow [-100  400]
% failed 
%   	histcounts.m > histcounts > 107
% 
% 		spkfun_getRasters.m > @(trial)histcounts(trial,hMin:hMax+1) > 8
% 
% 		spkfun_getRasters.m > spkfun_getRasters > 8
% 
% 		spkfun_sdf.m > spkfun_sdf > 112
% 
% 		DataModel.m > DataModel.getSdf > 74
% 
% 		DataModel.m > DataModel.getMultiUnitSdf > 38
% 
% 		processSessions.m > processSessions > 151
% 
% 		processDarwinK.m > processDarwinK > 20

  outcome = 'Correct';
  currCondition = {'targetOnset', 'right', [-100 400]};
  alignOn = currCondition{1};
  targetCondition = currCondition{2};
  sdfWindow = currCondition{3};
  % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
  [~, multiSdf] = model.getMultiUnitSdf(model.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
  
  

  
  
  
  