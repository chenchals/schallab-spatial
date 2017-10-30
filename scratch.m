darwin = {'D-Uprobe-MG-021616a-FEF.plx''D-Uprobe-MG-021916a-FEF.plx''D-Uprobe-MG-022216a-FEF.plx''D-Uprobe-MG-022316a-FEF.plx''D-Uprobe-MG-022516a-FEF.plx''D-Uprobe-MG-022616a-FEF.plx''D-Uprobe-MG-022916a-FEF.plx''D-Uprobe-MG-030316a-F2-FEF.plx''D-Uprobe-MG-030716a-F2-FEF.plx''D-Uprobe-MG-030816a-F2-FEF.plx''D-Uprobe-MG-031016a-F2-FEF.plx''D-Uprobe-MG-031116a-F2-FEF.plx'};helmholtz={'H-MG-120114a.plx''H-Uprobe-MG-120114b.plx''H-Uprobe-MG-120814a.plx''H-Uprobe-MG-121014a.plx''H-Uprobe-MG-121514a.plx''H-MG-121714a.plx''H-Uprobe-MG-010615a.plx''H-Uprobe-MG-012015a.plx''H-Uprobe-MG-012715a.plx''H-Uprobe-MG-021315a.plx''H-Uprobe-MG-022615a.plx''H-Uprobe-MG-031215a.plx'    };Z = helmholtz;toks=regexp(Z,'.*-(\d*[ab]).*','tokens')tok=cellfun(@(x) datestr(datenum(x{1},'mmddyya'),'yyyy-mm-dda') ,toks,'UniformOutput',false)% convert struct array to a struct with % a char field value ad field name% nhpSessions = % %   1�19 struct array with fields:% %     session%     mutilSdf%     info%     channelMap% ==> %%  nhpSessions(1)%% ans = % %   struct with fields:% %        session: 'jp054n01'%       mutilSdf: [1�1 struct]%           info: [1�27 table]%     channelMap: [32�1 double]load('clustering/schalllab-spatial/processed/testParfor.mat');finalVar = struct();for ro =1:numel(nhpSessions)    finalVar.(nhpSessions(ro).session) = nhpSessions(ro);end% cell array of structsZZ=nhpSessions;O = struct;for ii = 1:numel(ZZ)    t=ZZ{ii};    fn = fieldnames(t);    for f = 1:numel(fn)       O.(t.session).(fn{f})=t.(fn{f});    endendO2 = struct;for ii = 1:numel(ZZ)       O2.(ZZ{ii}.session)=ZZ{ii};endmatPath={'Users/Wolf/ephys_db/Darwin/2016-02-15a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-16a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-19a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-22a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-23a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-25a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-26a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-02-29a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-03-03a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-03-07a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-03-08a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-03-10a/DSP/DSP*/*MG*.mat''Users/Wolf/ephys_db/Darwin/2016-03-11a/DSP/DSP*/*MG*.mat'};srcDir = '/Users/chenchals/Projects/lab-schall/schalllab-clustering/data';  allSessions=cellfun(@(x) dir(fullfile(srcDir,x)),matPath,'UniformOutput',false);  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);  sessions = sessions(~cellfun(@isempty,sessions));      %%%%   %Create Map  eventVariables = {      'targOnset:targOn'      'responseOnset:responseOnset'      'targetLocation:targAngle'      'trialOutcome:trialOutcome'      };  temp = regexp(eventVariables,'^(.*):(.*)$','tokens');  k1=arrayfun(@(x) x{1}{1}{1},temp,'UniformOutput',false);  v1=arrayfun(@(x) x{1}{1}{2},temp,'UniformOutput',false);      % for Da  eventVariables = {      'targetOnset:Task.StimOnset'      'responseOnset:Task.Saccade'      'targetLocation:Task.TargetLoc'      'trialOutcome:' % logical      };  temp = regexp(eventVariables,'^(.*):(.*)$','tokens');  k=arrayfun(@(x) x{1}{1}{1},temp,'UniformOutput',false);  v=arrayfun(@(x) x{1}{1}{2},temp,'UniformOutput',false);  varMap = containers.Map(k,v);    vars = varMap.values;      %% Check DataModelWolf  srcFolder = '.';    matPath ='/Volumes/schalllab/Users/Wolf/ephys_db/Darwin/2016-03-11a/DSP/DSP*/*MG*.mat';  nhpTable.matPath = {matPath};  allSessions=cellfun(@(x) dir(fullfile(srcFolder,x)),nhpTable.matPath,'UniformOutput',false);  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);  sessions = sessions(~cellfun(@isempty,sessions));       session = sessions{1}; chMap=[1:16];  %chMap =[1, 2, 3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]';    D=DataModel.newInstance(DataModel.WOLF_DATA_MODEL,session,chMap);    evData = D.getEventData;      spkData = D.getSpikeData;      % spiketimes to cellArray  DSP02b=load('data/Users/Wolf/ephys_db/Darwin/2016-02-16a/DSP/DSP02b/2016-02-16a_DSP02b_MG_a.mat');  key = 'spikeTimes';  var = 'spiketimes';  temp.(var)=DSP02b.(var);  nTrials = size(temp.(var),1);for f=1:2    if f==2        temp.(var)(1,:)=nan(1,length(temp.(var)(1,:)));    end    for t = 1:nTrials        spikeData.(var){t,f}=temp.(var)(t,~isnan(temp.(var)(t,:)))';    end    spikeData2.(var){:,f} = arrayfun(@(t) temp.(var)(t,~isnan(temp.(var)(t,:)))',1:nTrials,'UniformOutput',false);end    % joule spikeData  jp=load('data/Joule/jp054n01.mat','spikeData');     %% Check DataModelKaleb  srcFolder = '.';    matPath ='/Volumes/schalllab/Users/Wolf/ephys_db/Darwin/2016-03-11a/DSP/DSP*/*MG*.mat';  nhpTable.matPath = {matPath};  allSessions=cellfun(@(x) dir(fullfile(srcFolder,x)),nhpTable.matPath,'UniformOutput',false);  sessions = cellfun(@(x) strcat({x.folder}',filesep,{x.name}'),allSessions,'UniformOutput',false);  sessions = sessions(~cellfun(@isempty,sessions));       session = sessions{1}; chMap=[1:16];  %chMap =[1, 2, 3, 4, 5,  6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32]';    D=DataModel.newInstance(DataModel.KALEB_DATA_MODEL,session,chMap);    evData = D.getEventData;      spkData = D.getSpikeData;        