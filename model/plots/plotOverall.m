function plotOverall(overall)

thresh = .5;

if ischar(overall)
    load(overall);
end

% Figure 1: Correlation matrix
rSquaredTmp = overall.rsquared;
rSquaredTmp(rSquaredTmp < thresh) = 0;

indivFields = fieldnames(overall);
        conFields = cellfun(@(x) strcmpi(x(1:min([6,length(x)])),'contra'),indivFields);
        ipFields = cellfun(@(x) strcmpi(x(1:min([4,length(x)])),'ipsi'),indivFields);
        myFields = indivFields(conFields | ipFields);
        nSubs = length(myFields);
        
        
        figure(); imagesc(rSquaredTmp);

% Figure 2: Plot out the SDFs
figure();
for i = 1:nSubs
    sdfP(i) = subplot(1,nSubs,i);
    imagesc(overall.(myFields{i}).sdfMeanZtr);
    title(myFields{i});
end
