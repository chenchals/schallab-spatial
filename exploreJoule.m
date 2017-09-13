function [multiSdf] = exploreJoule()
    clear all
    %delete(findobj('type','figure'))
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
            figure('Units','normalized', 'Position', [0.15 0.15 0.8 0.8]);
            sdfAll = cell2mat({multiSdf.(filename).sdf_mean}');
            subplot(1,2,1)
            imagesc(sdfAll)
            colorbar
            subplot(1,2,2)
            temp = (1-pdist2(sdfAll,sdfAll,'correlation')).^2;
            imagesc(temp)
            colorbar
        end
        
    end
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
