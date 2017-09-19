function [ nhpSessions ] = processSessions(nhpConfig)
%PROCESSSESSIONS Summary of this function goes here
%   Detailed explanation goes here

    nhpConfig.nhp = 'joule';
    nhpConfig.srcNhpDataFolder = '/Volumes/schalllab/data/Joule';
    nhpConfig.excelFile = '/Users/subravcr/Projects/lab-schall/schalllab-clustering/matlab/SFN_NHP_Coordinates_All.xlsx';
    nhpConfig.nhpSheetName = 'Jo';
    nhpConfig.outputFolder = '/Users/subravcr/Projects/lab-schall/schalllab-clustering/clustering/schalllab-spatial/testData';
    
    nhp = nhpConfig.nhp;
    srcNhpDataFolder = nhpConfig.srcNhpDataFolder;
    excelFile = nhpConfig.excelFile;
    nhpSheetName = nhpConfig.nhpSheetName;
    outputFolder = nhpConfig.outputFolder;
    outputFile = fullfile(outputFolder,nhp,[nhp 'Spatial.mat']);
    
    % Read excel sheet
    nhpTable = readtable(excelFile, 'Sheet', nhpSheetName);


    outcome ='saccToTarget';
    % Specify conditions to for creating multiSdf
    conditions{1} = {'left', 'targOn', [-100 400]};
    conditions{2} = {'left', 'responseOnset', [-300 200]};
    conditions{3} = {'right', 'targOn', [-100 400]};
    conditions{4} = {'right', 'responseOnset', [-300 200]};

    distancesToCompute = {'correlation'};
    nhpSessions = struct();
    % fix filenames - remove single quotes
    sessions =  strcat(srcNhpDataFolder, filesep, regexprep(nhpTable.Filename,'''',''),'.mat');
    for s = 1: size(nhpTable,1)
        nhpInfo = nhpTable(s,:);
        sessionLocation = sessions{s};
        fprintf('Processing file %s\n',sessionLocation);
        [~,session,~] = fileparts(sessionLocation);

        % Create instance of MemoryTypeModel
        jouleModel = EphysModel.newEphysModel('memory',sessionLocation);

        zscoreMinMax = nan(numel(conditions),2);
        distMinMax = struct();
        for c = 1:numel(conditions)
            currCondition = conditions{c};
            condStr = convertToChar(currCondition);
            % make conditions explicit for understanding
            targetCondition = currCondition{1};
            alignOn = currCondition{2};
            sdfWindow = currCondition{3};
            fprintf('Doing condition: outcome %s, alignOn %s, sdfWindow [%s]\n',...
                targetCondition, alignOn, num2str(sdfWindow));
            % Get MultiUnitSdf -> has sdf_mean matrix and sdf matrix
            [~, multiSdf.(condStr)] = jouleModel.getMultiUnitSdf(jouleModel.getTrialList(outcome,targetCondition), alignOn, sdfWindow);
            sdfPopulationZscoredMean = multiSdf.(condStr).sdfPopulationZscoredMean;
            zscoreMinMax(c,:) = minmax(sdfPopulationZscoredMean(:)');
            for d = 1: numel(distancesToCompute)
                distMeasureOption = distancesToCompute{d};
                dMeasure = pdist2(sdfPopulationZscoredMean, sdfPopulationZscoredMean,distMeasureOption);
                switch distMeasureOption
                    case 'correlation'
                        temp = (1-dMeasure).^2;
                        multiSdf.(condStr).rsquared = temp;
                        distMinMax.(distMeasureOption)(c,:) = minmax(temp(:)');
                    case {'euclidean', 'cosine'}
                        multiSdf.(condStr).rsquared = dMeasure;
                        distMinMax.(distMeasureOption )(c,:) = minmax(dMeasure(:)');
                    otherwise
                end
            end
        end
        nhpSessions.(session) = multiSdf;
        nhpSessions.(session).info = nhpInfo;
    end
    save(outputFile, '-struct', 'nhpSessions');
end

function [ condStr ] = convertToChar(condCellArray)
    indexChars = cellfun(@(x) ischar(x),condCellArray);
    charStr = char(join(condCellArray(indexChars),'_'));
    condStr = charStr;
end


