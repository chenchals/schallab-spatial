nContacts = 32;
delta = 100;
% contactIndex1 and contactIndex2  is 1 pair
pairs = nchoosek(1:nContacts,2); % 496 pairs = sum(1:nContacts-1)
distance = diff(pairs')'*delta;
corrVector = nan(numel(distance),1);
% Compute corrVector
% corrVector computation here
% dataTable with labels and corrVector
dataTable = table(corrVector, distance, pairs(:,1),pairs(:,2),...
    'VariableNames',{'corr','distance','chanIndex_1','chanIndex_2'});

% dataTable
%     corr    distance    chanIndex_1    chanIndex_2
%     ____    ________    ___________    ___________
% 
%     NaN      100         1              2         
%     NaN      200         1              3         
%     NaN      300         1              4         
%     NaN      400         1              5         
%     NaN      500         1              6         
%     ...
%     NaN      100        30             31         
%     NaN      200        30             32         
%     NaN      100        31             32         
