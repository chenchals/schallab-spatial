function [multiSdf, fxHandle ] = exploreJoule()
    clear all
    delete(findobj('type','figure'))
    plotIt = 1;
    % Get file list
    d = dir('/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/*.mat');
    jouleFiles = strcat({d.folder}', filesep, {d.name}');
    jouleFiles ={'/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp064n01.mat'};

    for f = 1:numel(jouleFiles)
        fullFileName = jouleFiles{f};
        fprintf('Processing file %s\n',fullFileName);        
        [~,filename,~] = fileparts(fullFileName);
        % Create instance of MemoryTypeModel
        jouleModel = EphysModel.newEphysModel('memory',fullFileName);
        outcome = {'saccToTarget'};
        targetCondition = {'right'};
        alignOn = 'responseOnset';
        sdfWindow = [-300 200];
        % Get MultiUnitSdf
        multiSdf.(filename) = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
        
        % Plot multiUnitSdf --> sorted by channelMap
        if plotIt
            % For rounfing firing rate to next 10 spikes/s 
            roundToNextN = 10; 
            tempSdf = multiSdf.(filename);
            maxFiringRate = max(max(cell2mat({tempSdf.sdf_mean}')));
            yLim = [0 ceil(maxFiringRate/roundToNextN)*roundToNextN];
            channelMap = jouleModel.getChannelMap();
            figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8]);
            for ii = 1:numel(channelMap)
                sdf = tempSdf(channelMap(ii));
                subplot(4,8,ii)
                plot(sdf.sdfWindow,sdf.sdf_mean)
                setLegend(sdf.spikeIds);
                drawnow
            end
            setFigureTitle(filename, 'outcome', outcome, 'targetLocation', targetCondition, 'alignOn', alignOn);
            set(findobj(gcf,'type','axes'),'XLim', sdfWindow); 
            
            % show heat map + distances...
            % Order sdf_mean by channelMap
            % Order sdf trials by channelMap 
            [ orderedSdfMean, orderedSdfTrials ] = reorderByLocation(multiSdf.(filename), channelMap);
            figure('Units','normalized', 'Position', [0.15 0.15 0.8 0.8]);
            sdfAll = cell2mat({multiSdf.(filename).sdf_mean}');
            subplot(1,3,1)
            imagesc(orderedSdfMean)
            colorbar
            subplot(1,3,2)
            temp = (1-pdist2(orderedSdfMean,orderedSdfMean,'correlation')).^2;
            imagesc(temp)
            colorbar
            subplot(1,3,3)
            temp = (1-pdist2(orderedSdfTrials,orderedSdfTrials,'correlation')).^2;
            imagesc(temp)
            colorbar
            setFigureTitle(filename, 'outcome', outcome, 'targetLocation', targetCondition, 'alignOn', alignOn);
        end
    end
    fxHandle = @reorderByLocation;
end


function [ orderedSdfMean, orderedSdfTrials, trialOrder ] = reorderByLocation(sdfStruct, channelOrder)
  orderedSdfMean = cell2mat({sdfStruct.sdf_mean}');
  orderedSdfMean = orderedSdfMean(channelOrder,:);
  nTrials = size(sdfStruct(1).sdf,1);
  % rows = nTrials*nChannels; cols = length(sdfWindow)
  orderedSdfTrials = cell2mat({sdfStruct.sdf}');
  % create ordering vector where
  % If there are 25 trials then
  % For channelOrder == 1 -> replace with 1:25
  % For channelOrder == 2 -> replace with 26:50
  % For channelOrder == 32 -> replace with 776:800
  trialOrder = cell2mat(arrayfun(@(x) [(x-1)*nTrials+1:x*nTrials],channelOrder,'UniformOutput',false))';
  orderedSdfTrials = orderedSdfTrials(trialOrder,:);
end


function [ h ] = setLegend(spikeIds)
    if numel(spikeIds) ==0
        spikeIds = {'none'};
    end
    outChar = regexp(spikeIds,'\d\d[a-z]','match');
    h = legend(char(join([outChar{:}],', ')));
    set(h,'Box','Off','FontWeight','bold')
end

function [ h ] = setFigureTitle(varargin)
    parts = {};
    for ii= 1:numel(varargin)
        arg =varargin{ii};
        if ischar(arg)
            parts = [parts {arg}];
        elseif iscellstr(arg)
            parts = [parts arg{:}];
        end
    end
    outChar = char(join(parts,'-'));
    h = axes('Units','Normal','Position',[.05 .05 .90 .90],'Visible','off');
    set(get(h,'Title'),'Visible','on');
    title(outChar,'fontSize',20,'fontWeight','bold')

end
