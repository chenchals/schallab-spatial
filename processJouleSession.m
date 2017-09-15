function [ multiSdf, sdfDist ] = processJouleSession(jouleFile)

    %jouleFile ='/Volumes/schalllab/Users/Chenchal/Jacob/data/joule/jp125n01.mat';
    maxChannels = 32;
    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    conditions{1} = {'left', 'targOn', [-100 400]};
    conditions{2} = {'left', 'responseOnset', [-300 200]};
    conditions{3} = {'right', 'targOn', [-100 400]};
    conditions{4} = {'right', 'responseOnset', [-300 200]};
    
    distToCompute = {'correlation'};
    
    fullFileName = jouleFile;
    fprintf('Processing file %s\n',fullFileName);
    [~,filename,~] = fileparts(fullFileName);
    
    % Create instance of MemoryTypeModel
    jouleModel = EphysModel.newEphysModel('memory',fullFileName);
    channelMap = jouleModel.getChannelMap();
    nTrials = 0;
    for c = 1:numel(conditions)
        currCondition = conditions{c};
        condStr = convertToChar(currCondition);
        % make conditions explicit for understanding
        targetCondition = currCondition{1};
        alignOn = currCondition{2};
        sdfWindow = currCondition{3};
        % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
        [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
        sdf = multiSdf.(condStr).sdf;
        sdf_mean = multiSdf.(condStr).sdf_mean;
        nTrials = multiSdf.(condStr).nTrials;
        for d = 1: numel(distToCompute) 
          distMeasure = distToCompute{d};
          switch distMeasure
              case 'correlation'
                  temp = (1-pdist2(sdf,sdf,distMeasure)).^2;
                  sdfDist.sdf.([distMeasure '_squared']).(condStr) = temp;
                  sdfDist.sdf_blurred.([distMeasure '_squared']).(condStr) = imgaussfilt(temp,nTrials*0.25);
                  temp = (1-pdist2(sdf_mean, sdf_mean,distMeasure)).^2;
                  sdfDist.sdf_mean.([distMeasure '_squared']).(condStr) = temp;
              otherwise
          end
        end
    end
    
    % plots
%     figH = figure('Units','normalized', 'Position', [0.05 0.05 0.9 0.9]);
%     set(0, 'currentfigure', figH);
    plotHandles = plot28axes;
    figH = get(plotHandles(1),'Parent');
    columnConditions={
        'left_targOn'
        'right_targOn'
        'left_responseOnset'
        'right_responseOnset'
        };
    rowConditions = {
        'sdf_mean'
        'sdf_mean.correlation_squared'
        'sdf.correlation_squared'
        'sdf_blurred.correlation_squared'
        };
    % The figure is 4 rows by 7 columns
    % col 1 = left_targOn col 2 = right_targOn
    channelTicks = 4:4:32;
    channelTickLabels = arrayfun(@(x) ['#' num2str(x)],channelTicks,'UniformOutput',false);
    for col = 1:4
        currPlots = plotHandles((col-1)*4+1:col*4);
        colCond = columnConditions{col};
        for ro = 1:4
            rowCond = rowConditions{ro};
            currplotHandle = currPlots(ro);
            set(figH, 'currentaxes', currplotHandle);
            currAxes = gca;
            switch ro
                case 1 %Firing Rate heatmap
                    imagesc(multiSdf.(colCond).(rowCond)); colorbar;
                    timeWin = multiSdf.(colCond).sdfWindow;
                    nTrials = multiSdf.(colCond).nTrials; % will be set for every column
                    step = range(timeWin)/5;
                    currAxes.XTick = 0:step:range(timeWin);
                    currAxes.XTickLabel = arrayfun(@(x) num2str(x),min(timeWin):step:max(timeWin),'UniformOutput',false);
                    
                    align0 = find(min(timeWin):max(timeWin)==0);
                    line([align0 align0], ylim, 'Color','r');
                    
                    currAxes.YTick = channelTicks;
                    currAxes.YTickLabel = channelTickLabels;
                    
                    titleText = colCond;
                    titleXpos = range(timeWin)/2;
                    titleYpos = min(ylim) - range(ylim)/10;
                    text(titleXpos,titleYpos,upper(titleText),...
                        'FontWeight','bold','FontAngle','italic','FontSize',14,'Color','b',...
                        'HorizontalAlignment', 'center', 'VerticalAlignment', 'cap',...
                        'Interpreter','none');
                                       
                case 2 % distance matrix for sdf_mean
                    imagesc(eval(['sdfDist.' rowCond '.' colCond ';']));colorbar;
                    currAxes.XTick = channelTicks;
                    currAxes.XTickLabelRotation = 90;
                    currAxes.XTickLabel = channelTickLabels;
                    
                case {3, 4} % distance matrix for trails
                    imagesc(eval(['sdfDist.' rowCond '.' colCond ';']));colorbar;
                    currAxes.XTick = channelTicks*nTrials;
                    currAxes.XTickLabelRotation = 90;
                    currAxes.XTickLabel = channelTickLabels;

            end
            drawnow
        end
    end
    
    
    
%     for ros = 1:2
%         if ros == 1 % align on targOn
%             pl1 = multiSdf.saccToTarget_left_targOn_minus100to400.sdf_mean;
%             pl2 = sdfDist.sdf_mean.correlation_squared.saccToTarget_left_targOn_minus100to400;
%             pl3 = sdfDist.sdf.correlation_squared.saccToTarget_left_targOn_minus100to400;
%             pl4 = imgaussfilt(pl3,sigmaImgFilter);
%             % reflect
%             pl8 = multiSdf.saccToTarget_right_targOn_minus100to400.sdf_mean;
%             pl7 = sdfDist.sdf_mean.correlation_squared.saccToTarget_right_targOn_minus100to400;
%             pl6 = sdfDist.sdf.correlation_squared.saccToTarget_right_targOn_minus100to400;
%             pl5 = imgaussfilt(pl6,sigmaImgFilter);
%         else % align on responseOnset
%             pl1 = multiSdf.saccToTarget_right_responseOnset_minus300to200.sdf_mean;
%             pl2 = sdfDist.sdf_mean.correlation_squared.saccToTarget_left_responseOnset_minus300to200;
%             pl3 = sdfDist.sdf.correlation_squared.saccToTarget_left_responseOnset_minus300to200;
%             pl4 = imgaussfilt(pl3,sigmaImgFilter);
%             % reflect
%             pl8 = multiSdf.saccToTarget_right_responseOnset_minus300to200.sdf_mean;
%             pl7 = sdfDist.sdf_mean.correlation_squared.saccToTarget_right_responseOnset_minus300to200;
%             pl6 = sdfDist.sdf.correlation_squared.saccToTarget_right_responseOnset_minus300to200;
%             pl5 = imgaussfilt(pl6,sigmaImgFilter);            
%         end
%         
%         for subp = 1:8
%             plotPos = subp+(ros-1)*8;
%             subplot(2,8,plotPos)
%             imagesc(eval(['pl' num2str(subp)]));
%         end
%     end
    
end

function [ condStr ] = convertToChar(condCellArray)
  indexChars = cellfun(@(x) ischar(x),condCellArray);
  charStr = char(join(condCellArray(indexChars),'_'));
%   numStr = cellfun(@(x) num2str(x),condCellArray(~indexChars),'UniformOutput',false);
%   numStr = char(join(numStr,'_'));
%   numStr = regexprep(numStr,'-','minus');  
%   numStr = regexprep(numStr,'\s+','to');
%   condStr = [charStr '_' numStr];
   condStr = charStr;
end



