load('da-files.mat')
da1=daFiles{1};
load(char(da1{25}))


trialList = ismember(Task.TaskType,'MG')' ... % get MG trials vector
                          & ...
             Task.TargetLoc == targRF(im);

%line 83:

if (...
        (iu > 1)...
        && ... % sub-cond evaluated only if iu>1 is true
        (...
        size(...
            spiketimes(... % Rows of spiketimes = trialList
                      ismember(Task.TaskType,'MG')' ... % get MG trials vector
                      & ...
                      Task.TargetLoc == targRF(im)... % target location vector
            ,:)...
        ,1) ... %size(spiketimes(trialList,:),1)
        == size(chanSpks,1) ...
        )... %close for &&
    )...
    || ...
    isempty(chanSpks) % No chanSpks
    % end of condition



end


% line 84
% Create Multi Unit spiketimes by concatenating matrices for:
%   Single units 
%   For a given channel
%     cat Concatenate arrays
%     cat(DIM,A,B) concatenates the arrays A and B along
%     the dimension DIM.  
%     cat(2,A,B) is the same as [A,B].
% Create multi unit spikes by trial for
%   each singleUnit 
%   for a channel
chanSpks = ...
    cat(2,...
        chanSpks,...% existing single unit spiketime matrix for curr channel
        spiketimes(...% *next* single unit spiketime matrix for current channel
        ismember(Task.TaskType,'MG')'...
        & Task.TargetLoc == targRF(im),...
        :)...
    ); % end cat

% Events
% getEventTime(code,codeMat,timeMat) => 
% code = TEMPO_CODES.Target_,TEMPO_CODES.Saccade_
% codeMat = EVcodes
% timeMat = EVtimes
%code = TEMPO_CODES.Target_;
codeMat = EVcodes;
timeMat = EVtimes;
nTrials = size(EVcodes,1);
ev = struct();

codes2get =[ 
    TEMPO_CODES.TrialStart_
    TEMPO_CODES.FixSpotOn_  
    TEMPO_CODES.Target_ 
    TEMPO_CODES.Saccade_];
for jj = 1:numel(codes2get)
    code = codes2get(jj);
    name = TEMPO_CODES.names{find(TEMPO_CODES.codes==code)}; %#ok<FNDSB>
    [ir,ic] = find(codeMat==code);
    for ii = 1:length(ir)
        ev.(name)(ir(ii),1) = timeMat(ir(ii),ic(ii));
    end
end

% TEMP_CODES Names for each trial...
zz = cell(nTrials,1);
for ii = 1:nTrials
   zz{ii,1}={TEMPO_CODES.names{cell2mat(arrayfun(@(x) find(TEMPO_CODES.codes==x),EVcodes(ii,:),'UniformOutput',false))}};
end

