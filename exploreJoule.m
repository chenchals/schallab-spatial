function [multiSdf] = exploreJoule()
    clear all
    delete(findobj('type','figure'))
    plotIt = 1;
    % Get file list
    d = dir('/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/*.mat');
    jouleFiles = strcat({d.folder}', filesep, {d.name}');
    %jouleFiles ={'/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp064n01.mat'};

    for f = 1:numel(jouleFiles)
        fullFileName = jouleFiles{f};
        fprintf('Processing file %s\n',fullFileName);        
        [~,filename,~] = fileparts(fullFileName);
        % Create instance of MemoryTypeModel
        jouleModel = EphysModel.newEphysModel('memory',fullFileName);
        outcome = {'saccToTarget'};
        targetCondition = {'right'};
        alignOn = 'responseOnset';

        % Get MultiUnitSdf
        multiSdf.(filename) = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, [-300 200]);

        if plotIt        % Plot multiUnitSdf ? as recorded
            % Plot multiUnitSdf --> sorted by channelMap
            tempSdf = multiSdf.(filename);
            channelMap = jouleModel.getChannelMap();
            figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8])
            setFigureTitle(filename, 'outcome', outcome, 'targetLocation', targetCondition, 'alignOn', alignOn);
            for ii = 1:numel(channelMap)
                sdf = tempSdf(channelMap(ii));
                subplot(4,8,ii)
                plot(sdf.sdfWindow,sdf.sdf_mean)
                setLegend(sdf.spikeIds);
                drawnow
            end
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
