function [ multiSdf, sdfDist ] = processJouleSession()

    jouleFile ='/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp064n01.mat';
    
    % Specify conditions to for creating multiSdf
    conditions{1} = {'saccToTarget', 'left', 'targOn', [-100 400]};
    conditions{2} = {'saccToTarget', 'left', 'responseOnset', [-300 200]};
    conditions{3} = {'saccToTarget', 'right', 'targOn', [-100 400]};
    conditions{4} = {'saccToTarget', 'right', 'responseOnset', [-300 200]};
    
    distToCompute = {'correlation'};

    fullFileName = jouleFile;
    fprintf('Processing file %s\n',fullFileName);
    [~,filename,~] = fileparts(fullFileName);
    
    % Create instance of MemoryTypeModel
    jouleModel = EphysModel.newEphysModel('memory',fullFileName);
    channelMap = jouleModel.getChannelMap();
    for c = 1:numel(conditions)
        currCondition = conditions{c};
        condStr = convertToChar(currCondition);
        % make conditions explicit for understanding
        outcome = currCondition{1};
        targetCondition = currCondition{2};
        alignOn = currCondition{3};
        sdfWindow = currCondition{4};
        % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
        [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
        sdf = multiSdf.(condStr).sdf;
        sdf_mean = multiSdf.(condStr).sdf_mean;
        
        for d = 1: numel(distToCompute) 
          distMeasure = distToCompute{d};
          switch distMeasure
              case 'correlation'
                  sdfDist.sdf.([distMeasure '_squared']).(condStr) = (1-pdist2(sdf,sdf,distMeasure)).^2;
                  sdfDist.sdf_mean.([distMeasure '_squared']).(condStr) = (1-pdist2(sdf_mean, sdf_mean,distMeasure)).^2;
              otherwise
          end
        end
    end
    
    % plots
    % 2 by 6
    filtSig = 20;
    figure('Units','normalized', 'Position', [0.1 0.1 0.8 0.8]);
    for ros = 1:2
        if ros == 1 % align on targOn
            pl1 = multiSdf.saccToTarget_left_targOn_minus100to400.sdf_mean;
            pl2 = sdfDist.sdf_mean.correlation_squared.saccToTarget_left_targOn_minus100to400;
            pl3 = sdfDist.sdf.correlation_squared.saccToTarget_left_targOn_minus100to400;
            pl4 = imgaussfilt(pl3,filtSig);
            % reflect
            pl8 = multiSdf.saccToTarget_right_targOn_minus100to400.sdf_mean;
            pl7 = sdfDist.sdf_mean.correlation_squared.saccToTarget_right_targOn_minus100to400;
            pl6 = sdfDist.sdf.correlation_squared.saccToTarget_right_targOn_minus100to400;
            pl5 = imgaussfilt(pl6,filtSig);
        else % align on responseOnset
            pl1 = multiSdf.saccToTarget_right_responseOnset_minus300to200.sdf_mean;
            pl2 = sdfDist.sdf_mean.correlation_squared.saccToTarget_left_responseOnset_minus300to200;
            pl3 = sdfDist.sdf.correlation_squared.saccToTarget_left_responseOnset_minus300to200;
            pl4 = imgaussfilt(pl3,filtSig);
            % reflect
            pl8 = multiSdf.saccToTarget_right_responseOnset_minus300to200.sdf_mean;
            pl7 = sdfDist.sdf_mean.correlation_squared.saccToTarget_right_responseOnset_minus300to200;
            pl6 = sdfDist.sdf.correlation_squared.saccToTarget_right_responseOnset_minus300to200;
            pl5 = imgaussfilt(pl6,filtSig);            
        end
        
        for subp = 1:8
            plotPos = subp+(ros-1)*8;
            subplot(2,8,plotPos)
            imagesc(eval(['pl' num2str(subp)]));
        end
    end
    
end

function [ condStr ] = convertToChar(condCellArray)
  indexChars = cellfun(@(x) ischar(x),condCellArray);
  charStr = char(join(condCellArray(indexChars),'_'));
  numStr = cellfun(@(x) num2str(x),condCellArray(~indexChars),'UniformOutput',false);
  numStr = char(join(numStr,'_'));
  numStr = regexprep(numStr,'-','minus');  
  numStr = regexprep(numStr,'\s+','to');
  condStr = [charStr '_' numStr];
end


