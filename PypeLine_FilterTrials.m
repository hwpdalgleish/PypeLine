function [filt_trial_info] = PypeLine_FilterTrials(trial_info,filters)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filter Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Henry Dalgleish (2016) for use with PyBehaviour data (Lloyd Russell 2016)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - trial_info : cell array where each cell is the num_trials * 10 session
%                data parsed by PypeLine_Master
% - filters    : vector of column number/value pairs to filter data with 
%                (space separated). N.B. can enter more than one column 
%                number/value pair (space separated).
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Examples %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% E.g. to filter column 1 for values of 0 of trial_info variable x:
% PypeLine_FilterTrials(x,[1 0])
%
% E.g. to filter column 1 for values of 0 and column 3 for 2 of trial_info
% varriable x:
% PypeLine_FilterTrials(x,[1 0 3 2])
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%% Trial_info columns %%%%%%%%%%%%%%%%%%%%%%%%%%%
%
%   1   withold req
%   2   prestim delay
%   3   stim type
%   4   stim variation
%   5   poststim delay
%   6   response time
%   7   response required
%   8   response given
%   9   correct (0 or 1)
%   10  miss (0 or 1)
%   11  autoreward (0 or 1)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

filters = filters(:);

if mod(length(filters),2)
    
    error(sprintf(['\n******************** Error ********************'...
                   '\nOne of your column/value pairs does not contain'...
                   '\n         both a column index and a value'...
                   '\n***********************************************'])) 
    
end

col_val = [filters(1:2:end) filters(2:2:end)];

numsess = numel(trial_info);

filt_trial_info = cell(1,numsess);

for a = 1:numsess
    
    idcs = ones(size(trial_info{a},1),1);

    for i = 1:size(col_val,1)
        
        idcs = idcs & (trial_info{a}(:,col_val(i,1)) == col_val(i,2));
        
    end
    
    filt_trial_info{a} = trial_info{a}(idcs,:);

end

end

