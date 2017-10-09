  %% Check DataModelKaleb
  % has 1-64
  srcFolder = '';
  matPath ='/Volumes/schalllab/Users/Kaleb/dataProcessed/Init_SetUp-160921-141512/Channel*/chan*.mat';
  nhpTable.matPath = {matPath};
  %nhpTable.ephysChannelMap = {(1:32)'};
  nhpTable.ephysChannelMap = {(33:64)'};
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
  sessions = outSessions;
  
  session = sessions{1}; chMap=nhpTable.ephysChannelMap{1};
  %chMap =[1, 2, 3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]';
  
  D=DataModel.newInstance(DataModel.KALEB_DATA_MODEL,session,chMap);
  
  % for event data
  % get the behavior file location
  f = fullfile(char(cellfun(@char,regexp(f,'^(.*-\d*)/.*','tokens'),'UniformOutput',false)),'Behav.mat');
  
  
  evData = D.getEventData;
  
  
  spkData = D.getSpikeData;