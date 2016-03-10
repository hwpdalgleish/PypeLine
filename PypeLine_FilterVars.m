function [filt_var_info] = PypeLine_FilterVars(trial_info,filters)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Filter Trials %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% Henry Dalgleish (2016) for use with PyBehaviour data (Lloyd Russell 2016)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Inputs %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% - trial_info : cell array where each cell is the num_trials * 10 session
%                data parsed by PypeLine_Master
% - filters    : column numbers to return (space separated)
%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Examples %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
% E.g. to return column 1 variable x:
% PypeLine_FilterTrials(x,1)
%
% E.g. to return columns 1, 3 and 6 of variable x:
% PypeLine_FilterTrials(x,[1 3 6])
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

filt_var_info = cellfun(@(x) x(:,filters),trial_info,'UniformOutput',0);

end

