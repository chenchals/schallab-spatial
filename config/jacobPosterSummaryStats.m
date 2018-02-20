baseDir = 'processedJacob/poster/';
spacings = [100,150,200];
conditions = {'contra_targetOnset' 'contra_responseOnset'};
bootsOrObservedFields = {'observed' 'boots'};
oFile = fullfile(baseDir,'posterClusterStats.xlsx');
for spaceIndex = 1:numel(spacings)
    spacing = spacings(spaceIndex);
    spacingStr = num2str(spacing);
    for condIndex = 1:numel(conditions)
        condStr = conditions{condIndex};
        ZZ = load(fullfile(baseDir,['posterClustersAllNhps_' condStr '.mat']));
        nhps = ZZ.nhps;
        for bootsOrObsIndex = 1:numel(bootsOrObservedFields)
            bootsOrObserved = bootsOrObservedFields{bootsOrObsIndex};
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
            
            writetable(description,oFile,'Sheet',['size_' condStr],'Range',descriptionRange)
            writetable(sizeStats,oFile,'Sheet',['size_' condStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            writetable(description,oFile,'Sheet',['dist_' condStr],'Range',descriptionRange)
            writetable(distStats,oFile,'Sheet',['dist_' condStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            writetable(description,oFile,'Sheet',['num_' condStr],'Range',descriptionRange)
            writetable(numStats,oFile,'Sheet',['num_' condStr],'WriteRowNames',true,'WriteVariableNames',true,'Range',rangeStart)
            
            clearvars -regexp .*Size.* .*Dist.* .*Num.* .*Stats.*
        end % boots or observed
    end % for each condition
end % for each spacing
