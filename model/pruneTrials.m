function [ dataStruct ] = pruneTrials( trialsByCategory, minTrialCount, dataStruct )
%PRUNETRIALS Remove all trials where the total no. of trials is <
%minTrialCount per condition 

    [trialCount, uniqCategory] = hist(trialsByCategory,  unique(trialsByCategory));
    trials2Retain = cell2mat(arrayfun(@(x) find(trialsByCategory==x)...
        ,uniqCategory(trialCount >= minTrialCount),'UniformOutput',false));
    dataStruct = structfun(@(field) field(trials2Retain,:)...
        ,dataStruct,'UniformOutput',false);
end


