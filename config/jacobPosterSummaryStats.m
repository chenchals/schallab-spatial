baseDir = 'processed/poster2/';
spacings = [100,150,200];
conditions = {'contra_targetOnset' 'contra_responseOnset'};
condSheetNameStr = {'C_TargOn' 'C_respOn'};
bootsOrObservedFields = {'observed' 'boots'};
oFile = fullfile(baseDir,'posterClusterStats.xlsx');
oFile2 = fullfile(baseDir,'posterClusterDistribution.xlsx');
warning off
for spaceIndex = 1:numel(spacings)
    spacing = spacings(spaceIndex);
    spacingStr = num2str(spacing);
    fprintf('Doing spacing %s\n',spacingStr);
    for condIndex = 1:numel(conditions)
        condStr = conditions{condIndex};
        ZZ = load(fullfile(baseDir,['posterClustersAllNhps_' condStr '.mat']));
        nhps = ZZ.nhps;
        fprintf('Doing condition %s\n',condStr);
        for bootsOrObsIndex = 1:numel(bootsOrObservedFields)
            bootsOrObserved = bootsOrObservedFields{bootsOrObsIndex};
            fprintf('Doing Boot/observed %s\n',bootsOrObserved);
            % for each NHP get distribution of cluster sizes from boots or observed for all sessions
            for ii = 1:numel(nhps)
                nhp = nhps{ii};
                sessions = fieldnames(ZZ.(nhp));
                %sessions with seleced channelSpacing
                sessions = sessions(arrayfun(@(x) ZZ.(nhp).(x{1}).info.channelSpacing==spacing,sessions));
                
                cSizes = cellfun(@(x) [ZZ.(nhp).(char(x)).(condStr).(bootsOrObserved).cSize], sessions,'UniformOutput',false);
                cDists = cellfun(@(x) [ZZ.(nhp).(char(x)).(condStr).(bootsOrObserved).dtnc], sessions,'UniformOutput',false);
                cNums = cellfun(@(x) cellfun(@length,{ZZ.(nhp).(x).(condStr).(bootsOrObserved).cSize}),sessions,'UniformOutput',false);
                
                nhpCSizes{ii} = [cSizes{:}];
                nhpCDists{ii} = [cDists{:}];
                nhpCNums{ii} = [cNums{:}];
                
            end
            
            % all monks
            nhpSizes = [nhpCSizes{:}];
            nhpDists = [nhpCDists{:}];
            nhpNums = [nhpCNums{:}];
            
            % Statistics
            nhpCSizeStats = getStats(nhps, nhpCSizes);
            nhpCDistStats = getStats(nhps, nhpCDists);
            nhpCNumStats = getStats(nhps, nhpCNums);
            
            nhpSizeStats = getStats({'Global'},{nhpSizes});
            nhpDistStats = getStats({'Global'},{nhpDists});
            nhpNumStats = getStats({'Global'},{nhpNums});
            
            sizeStats = [nhpCSizeStats;nhpSizeStats];
            distStats = [nhpCDistStats;nhpDistStats];
            numStats = [nhpCNumStats;nhpNumStats];
            
            desc=char(join({condStr, bootsOrObserved,'channelSpacing',spacingStr},'_'));
            description = table({desc});
            description.Properties.VariableNames={desc};
            startRow = (spaceIndex-1)*10 + 1;
            if bootsOrObsIndex == 1
                descriptionRange = ['A' num2str(startRow)];
                rangeStart = ['A' num2str(startRow+1)];
            else
                descriptionRange = ['J' num2str(startRow)];
                rangeStart = ['J' num2str(startRow+1)];
            end
            
            condSheetStr = condSheetNameStr{condIndex};
            
            writetable(description,oFile,'Sheet',['size_' condSheetStr],'Range',descriptionRange)
            writetable(sizeStats,oFile,'Sheet',['size_' condSheetStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            writetable(description,oFile,'Sheet',['dist_' condSheetStr],'Range',descriptionRange)
            writetable(distStats,oFile,'Sheet',['dist_' condSheetStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            writetable(description,oFile,'Sheet',['num_' condSheetStr],'Range',descriptionRange)
            writetable(numStats,oFile,'Sheet',['num_' condSheetStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            
            % write distribution tables
            if bootsOrObsIndex == 1
                bo = 'OBS';
                rangeStart = ['A' num2str(1)];
            else
                bo = 'BOO';
                rangeStart = ['C' num2str(1)];
            end
            histBins = 0:100:(ceil(max(nhpSizes)/100)*100+100);
            numBins = 0:32;
            histSizes = histc(nhpSizes,histBins)';
            histDists = histc(nhpDists,histBins)';
            histNums = histc(nhpNums,numBins)';
            
            baseSheetName = [condSheetStr '_' bo '_' spacingStr];
            writetable(array2table(nhpSizes(:),'VariableNames',{'clust_size'}),oFile2,'Sheet', ['size_' baseSheetName],'WriteVariableNames',true); 
            writetable(array2table([histBins(:) histSizes],'VariableNames',{'clust_size','freq'}),oFile2,'Sheet', ['size_H_' baseSheetName],'WriteVariableNames',true);
            writetable(array2table(nhpDists(:),'VariableNames',{'dtnc'}),oFile2,'Sheet', ['dtnc_' baseSheetName],'WriteVariableNames',true); 
            writetable(array2table([histBins(:) histDists],'VariableNames',{'dtnc','freq'}),oFile2,'Sheet', ['dtnc_H_' baseSheetName],'WriteVariableNames',true);
            writetable(array2table(nhpNums(:),'VariableNames',{'num_clusts'}),oFile2,'Sheet', ['nums_' baseSheetName],'WriteVariableNames',true); 
            writetable(array2table([numBins(:) histNums],'VariableNames',{'num_clusts','freq'}),oFile2,'Sheet', ['nums_H_' baseSheetName],'WriteVariableNames',true);
             
            clearvars -regexp .*Size.* .*Dist.* .*Num.* .*Stats.*
        end % boots or observed
    end % for each condition
end % for each spacing
