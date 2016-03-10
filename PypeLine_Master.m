%% 

%%%% Set directory containing animal id directors 
%    (e.g. H21 for Henry's mouse 21)
path = uigetdir('', 'Select PyBehaviour results directory');

%%%% User variables

experimentor_id = 'L'; % Experimentor initial

max_num_trials = 120; % max number of trials/session to take

min_num_trials = 40; % exclude sessions with number of trials less than this

discard_miss = 0; % discard miss trials in P(correct) calculations

%%%% Parse and organise data

fieldnames = {'withold_req' ...
              'pre_stim_delay' ...
              'stim_type' ...
              'stim_var' ...
              'post_stim_delay' ...
              'responses' ...
              'response_required' ...
              'firstresponse' ...
              'correct' ...
              'miss' ...
              'auto_reward'};
              
d = dir(path);

tdata = struct;

tdata.id = {};

tdata.date = {};

tdata.trial_info = [];

tdata.percent_correct = [];

tdata.rxn_time = {};

tdata.choice_bias = [];

tdata.percent_miss = [];

tdata.num_trials = [];

tdata.session_flag = [];

animaldirs = find(cellfun(@(x) ~isempty(x),cellfun(@(x) strfind(x,experimentor_id),{d.name},'UniformOutput',0)));

loaded = [];

m = {};

mti = {};

for a = 1:numel(animaldirs)
    
    tdata(a).id = d(animaldirs(a)).name;
    
    adir = [path filesep d(animaldirs(a)).name];
    
    ad = dir(adir);
    
    files = {ad.name};
    
    matfiles = find(cellfun(@(x) ~isempty(x),cellfun(@(x) strfind(x,'.mat'),files,'UniformOutput',0)));
    
    prevdate = [];
    
    prevflag = -1;
    
    fac = 0;
    
    % Step through sessions
    
    for ts = 1:numel(matfiles)

        f = ad(matfiles(ts)).name;
        
        try
        
            dat = load([adir filesep f]);
            
            loaded = 1;
            
            numtrials = numel(dat.results);
        
            rxntime = cell(2,1);
        
            if ~strcmp(prevdate,f(6:13))
        
                unilateral = cell(1,2);
            
            end
            
        catch
            
            sprintf(['Warning: unable to load ' f ', file may be corrupt or contain no data. Skipping...'])
            
            loaded = 0;
            
            fac = fac + 1;
            
        end
            
        if loaded
            
            if numtrials > min_num_trials
                
                if numtrials < max_num_trials
                    
                    maxidx = numel(dat.results);
                    
                else
                    
                    maxidx = max_num_trials;
                    
                end
                
                rewardchannels = dat.results{1}.parameters.rewardChannels;
                
                stimchannels = dat.results{1}.parameters.stimChannels;
                
                numstims = numel(stimchannels);
                
                trial_info = [];
                
                % Step through trials
                
                for i = 1:maxidx
                    
                    if min(isfield(dat.results{i},fieldnames));
                        
                        if ~dat.results{i}.miss
                            
                            %[withold_req | prestim delay | stim_type | stim_var | poststim delay | response time | response required | response given | correct | miss | autoreward]
                            
                            trial_info(end+1,:) = [double(dat.results{i}.withold_req) ...
                                dat.results{i}.pre_stim_delay ...
                                double(dat.results{i}.stim_type) ...
                                double(dat.results{i}.stim_var) ...
                                dat.results{i}.post_stim_delay ...
                                dat.results{i}.responses(1,find(dat.results{i}.responses(1,:) > 0,1,'First')) ...
                                double(dat.results{i}.response_required) ...
                                double(dat.results{i}.firstresponse) ...
                                double(dat.results{i}.correct) ...
                                double(dat.results{i}.miss) ...
                                double(dat.results{i}.auto_reward)];
                            
                            rxntime{stimchannels == dat.results{i}.stim_type}(end+1,1) = trial_info(i,6);
                            
                            unilateral{rewardchannels == dat.results{i}.response_required}(end+1,1) = dat.results{i}.correct;

                        elseif dat.results{i}.miss && ~discard_miss
                            
                            %[withold_req | prestim delay | stim_type | stim_var | poststim delay | no response time (nan) | response required | no response given (0) | correct | miss | autoreward]
                            
                            trial_info(end+1,:) = [double(dat.results{i}.withold_req) ...
                                dat.results{i}.pre_stim_delay ...
                                double(dat.results{i}.stim_type) ...
                                double(dat.results{i}.stim_var) ...
                                dat.results{i}.post_stim_delay ...
                                nan ...
                                double(dat.results{i}.response_required) ...
                                double(dat.results{i}.firstresponse) ...
                                double(dat.results{i}.correct) ...
                                double(dat.results{i}.miss) ...
                                double(dat.results{i}.auto_reward)];
                            
                        end
                        
                    end
                    
                end
                
                numtrials = size(trial_info,1);
                
                choice_bias = cellfun(@(x) mean(x),unilateral);
                
                choice_bias(isnan(choice_bias)) = 0;
                
                session_flag = ~isempty(dat.results{1}.parameters.notes); 
                
                % Add trial data to structure and merge/separate
                % depending on date/flags
                
                if strcmp(prevdate,f(6:13)) && session_flag == prevflag
                    
                    fac = fac+1;
                    
                    tdata(a).trial_info{ts-fac} = [tdata(a).trial_info{ts-fac} ; trial_info];
                    
                    tdata(a).percent_correct(ts-fac,1) = mean(tdata(a).trial_info{ts-fac}(:,9));
                    
                    for s = 1:numstims
                        
                        tdata(a).rxn_time{ts-fac,s} = [tdata(a).rxn_time{ts-fac,s} ; rxntime{s}];
                        
                    end
                    
                    tdata(a).choice_bias(ts-fac,:) = -diff(choice_bias,[],2);
                    
                    tdata(a).percent_miss(ts-fac,1) = mean(tdata(a).trial_info{ts-fac}(:,10));
                    
                    tdata(a).num_trials(ts-fac,:) = sum([tdata(a).num_trials(ts-fac,:) numtrials],2);
                    
                    tdata(a).session_flag(ts-fac) = session_flag;
                    
                elseif ~strcmp(prevdate,f(6:13)) || (strcmp(prevdate,f(6:13)) && session_flag ~= prevflag)
                    
                    tdata(a).date{ts-fac} = f(6:13);
                    
                    tdata(a).trial_info{ts-fac} = trial_info;
                    
                    tdata(a).percent_correct(ts-fac,1) = mean(trial_info(:,9));
                    
                    for s = 1:numstims
                        
                        tdata(a).rxn_time{ts-fac,s} = rxntime{s};
                        
                    end
                    
                    tdata(a).choice_bias(ts-fac,:) = -diff(choice_bias,[],2);
                    
                    tdata(a).percent_miss(ts-fac,1) = mean(tdata(a).trial_info{ts-fac}(:,10));
                    
                    tdata(a).num_trials(ts-fac,:) = numtrials;
                    
                    tdata(a).session_flag(ts-fac) = session_flag;
                    
                end
                
                prevdate = f(6:13);
                
                prevflag = session_flag;
                
            else
                
                fac = fac+1;
                
            end
            
        end
        
    end
    
end

%%%% Plot preliminary analysis

scrsz = get(0,'ScreenSize');

maxdays = max(cellfun(@(x) length(x),{tdata.percent_correct}));

numanimals = numel(tdata);

cmap = [0 0 0; hsv(numanimals)];

figure('Color',[1 1 1],'Position',[0 scrsz(4)/2 scrsz(3) scrsz(4)/3])

% P(Correct)

for a = 1:numanimals
    
    hold on
    
    a1 = subplot(1,4,1);
    
    plot(tdata(a).percent_correct,'Color',cmap(a,:))
    
end

xl(1) = xlabel('Days');

yl(1) = ylabel('P(Correct)');

xlim([0 maxdays+1])

ylim([0 1])

set(gca,'XTick',[1:1:maxdays])

set(gca,'YTick',[0:0.5:1])

line([min(xlim) max(xlim)],[0.5 0.5],'LineStyle','--','Color','r')

% Choice Bias

for a = 1:numanimals
    
    hold on
    
    a2 = subplot(1,4,2);
    
    plot(tdata(a).choice_bias,'Color',cmap(a,:))
    
end

xl(2) = xlabel('Days');

yl(2) = ylabel('Choice Bias');

ylim([-1.2 1.2])

xlim([0 maxdays+1])

set(gca,'YTick',[-1:1:1])

set(gca,'XTick',[1:1:maxdays])

line([min(xlim) max(xlim)],[0 0],'LineStyle','--','Color','r')

% Reaction time

for a = 1:numanimals
    
    hold on
    
    a2 = subplot(1,4,3);
    
    rxntimes_mean = cellfun(@(x) mean(x),tdata(a).rxn_time);
    
    rxntimes_sem = cellfun(@(x) mean(x),tdata(a).rxn_time) ./ sqrt(cellfun(@(x) numel(x),tdata(a).rxn_time));
 
    numdays = [1:size(tdata(a).rxn_time,1)];
    
    plot(numdays,rxntimes_mean(:,1),'Color',cmap(a,:))
    
    hold on
    
    plot(numdays,rxntimes_mean(:,2),'LineStyle','--','Color',cmap(a,:))
    
    eb(1) = errorbar(numdays,rxntimes_mean(:,1),rxntimes_sem(:,1));
    
    eb(2) = errorbar(numdays,rxntimes_mean(:,2),rxntimes_sem(:,2),'--');
    
    set(eb(1),'Color',cmap(a,:))
    
    set(eb(2),'Color',cmap(a,:))
    
end

xl(3) = xlabel('Days');

yl(3) = ylabel('Reaction Time (s)');

ylim([0 4]);

xlim([0 maxdays+1])

set(gca,'YTick',[0:0.5:max(ylim)])

set(gca,'XTick',[1:1:maxdays])

set(gcf,'Color',[1 1 1])

% Percentage misses

for a = 1:numanimals
    
    hold on
    
    a2 = subplot(1,4,4);
    
    numdays = [1:size(tdata(a).rxn_time,1)];
    
    plot(tdata(a).percent_miss,'Color',cmap(a,:))
    
end

xl(4) = xlabel('Days');

yl(4) = ylabel('P(Miss)');

ylim([0 1]);

xlim([0 maxdays+1])

set(gca,'YTick',[0:0.5:max(ylim)])

set(gca,'XTick',[1:1:maxdays])

% Format

set(gcf,'Color',[1 1 1])

axhands = get(gcf,'children');

for i = 1:numel(axhands)

    set(axhands(i),'box','off')
    
    set(axhands(i),'TickDir','out')
    
    set(axhands(i),'FontUnits','inches')
   
    set(axhands(i),'FontSize',0.18)
    
    set(axhands(i),'FontName','Helvetica')
    
    set(xl(i),'FontUnits','inches')
    
    set(xl(i),'FontSize',0.2)
    
    set(yl(i),'FontUnits','inches')
    
    set(yl(i),'FontSize',0.2)
    
end



