% ANALYSIS PHYSIO CORR and ZYGO
% get the data and calculate a zyg and a corr measure per subject
% plot mean CORR for gam, neg, pos, neu, (gry)
% plot mean ZYGO for gam, neg, pos, neu, (gry)
% WATCH OUT: GRY CATEGORY IS BEING DISCARDED HERE!!!

clear all
close all

%% parameters
pre = 1000;
post= 2000;
post_eda_on = 2000;
post_eda_off= 8000;

% overwrite or use existing extractions?
% ow overwrites if person does not exist yet, should always be 1
% ow_rf overwrites nomatter what (if you wanna do everything new)
ow    = 1;
ow_rf = 1;

% should signal be smoothed before doing the summary stat?
do_smoothing = 1;
% if do_smoothing: moving average params
lag     = 50;
p_alpha = 0.05;
% which function to use to characterize trial-based signal
% 'auc' for mean signal (sum of signal divided by number of samples)
% TODO: 'auc' rename to 'mean'n everywhere
% TODO: implement trimmed mean and the like
% 'pmv' is peak at max var within subject across trials; last trial, will
% try to extract, if too short then take the max of last trial
% 'max' for simply the max of the event
% 'median' for the median of the event
% provide a string cell array and it will do all of them
trial_summary_stats = {'auc','max','median','pmv'};
%trial_summary_stats = {'pmv'};
% which onset is desired:
desired_onset = 'stim';
% end of signal at reaction time or at set post value?
% must be 0 if 'peak_at_max_var'!
rt_end = 0;
% minumum reaction time needed
high_pass = 0.2;
% physio normalizing will be done by centering and scaling (2)
% i.e. flat line is mean activation (2)
% all activation is deviation from mean activation (2)
% (1): only mean scaling, no centering
% CURRENTLY NOT USED
scale_opt = 2;
% all sum stats get scaled within subs after summing again (none (0),
% centering only (1), both centering and scaling (2);
scale_auc = 2;

%% preparations
comp_name = getenv('USERNAME');
start_up

% base directory and other dirs
path_data      = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten';
base_dir       = fullfile(path_data,'PDT\pilot');
base_dir_PG    = fullfile(path_data,'PDT\PG');
base_dir_pp_PG = fullfile(path_data,'PDT\POSTPILOT\PG');
base_dir_pp_HC = fullfile(path_data,'PDT\POSTPILOT\HC');

% % at home
% base_dir       = ['E:\Google Drive\Promotion\' ... '
%     'VPPG\VPPG_Exchange\Experimente\PDT\Daten\pilot'];
% base_dir_PG    = ['E:\Google Drive\Promotion\' ...
%     'VPPG\VPPG_Exchange\Experimente\PDT\Daten\PG'];
% base_dir_pp_PG = ['E:\Google Drive\Promotion\VPPG\' ...
%     'VPPG_Exchange\Experimente\PDT\Daten\POSTPILOT\PG'];
% base_dir_pp_HC = ['E:\Google Drive\Promotion\VPPG\' ...
%     'VPPG_Exchange\Experimente\PDT\Daten\POSTPILOT\HC'];
% resu_dir       = ['E:\Google Drive\Promotion\VPPG\' ...
%     'VPPG_Exchange\Experimente\PDT\analysis\results\ml_plots'];
% path_data      = ['E:\Google Drive\Promotion\VPPG\' ...
%     'VPPG_Exchange\Experimente\PDT\Daten'];

% get names of subs that have been exported already
%needed_files = {'corr_auc.csv','eda_auc.csv','zygo_auc.csv'};
% needed_files = {'eda_auc.csv'};
% for kk = 1:length(needed_files)
%     cd(base_dir)
%     fid = fopen(needed_files{kk});
%     cur_dat = textscan(fid,'%s %s %s %s','Delimiter',',');
%     fclose(fid);
%     for jj = 1:length(cur_dat)
%         disp(unique(agk_round_cell(cur_dat{jj},1)));
%     end
% end


% get the data and plot mean zyg and corr for each group
cd(base_dir)
subs = dir('PhysioVP*');
for gg = 1:length(subs)
    subs(gg).name = [base_dir filesep subs(gg).name];
end
cd(base_dir_PG)
subs_PG = dir('Physio*');
for gg = 1:length(subs_PG)
    subs_PG(gg).name = [base_dir_PG filesep subs_PG(gg).name];
end
cd(base_dir_pp_PG)
subs_pp_PG = dir('Physio*');
for gg = 1:length(subs_pp_PG)
    subs_pp_PG(gg).name = [base_dir_pp_PG filesep subs_pp_PG(gg).name];
end
cd(base_dir_pp_HC)
subs_pp_HC = dir('Physio*');
for gg = 1:length(subs_pp_HC)
    subs_pp_HC(gg).name = [base_dir_pp_HC filesep subs_pp_HC(gg).name];
end
subs =  [subs;subs_PG;subs_pp_HC;subs_pp_PG];

% channel_names; category names
chn_nms = {'mark', 'eda', 'zygo', 'corr'};
cat_nms = {'gam','neg','pos','neu','gry'};

%% Running the data extraction
for ss = 1:length(trial_summary_stats)
    % for all summary stats
    trial_summary = trial_summary_stats{ss};
    disp(['RUNNING SUMMARY STAT: ' trial_summary]);
    % change into wd
    cd(base_dir)
    
    % load physio_data (for previously extracted physio data);
    if (~ow_rf)
        load(['physio_data_' trial_summary '.mat'])
    end
    
    % prep data cell for gathering new extracted data
    data_cell = {};
    
    for ii = 1:length(subs)
        % for all subjects
        if ow_rf == 1
            % recursive force: do all extracts anew
            extract_anew = 1;
        else
            % check if data is there already
            [a,b] = fileparts(subs(ii).name);
            tmp   = physio_data(:,1);
            for ll = 1:length(tmp)
                if isempty(tmp{ll})
                    tmp{ll} = '';
                end
            end
            person_there = cell2mat(strfind(tmp,b));
            if isempty(person_there)
                person_there = 0;
            elseif person_there == 1
                person_there = 1;
            else
                error(['Cannot decide if person''s data has already been ' ...
                    'extracted or not.'])
            end
            
            % checking if really all channels' data is there of that person
            if person_there == 1
                cur_dat   = physio_data(~(cellfun(@isempty,strfind(tmp,b))),:);
                if length(cur_dat(:,1)) > 1
                    disp([b ' is there more than once. Deleting' ...
                        ' from saved cell array and starting from top.'])
                    physio_data(~(cellfun(@isempty,strfind(tmp,b))),:) = [];
                    save(['physio_data_' trial_summary '.mat'],'physio_data')
                    get_physio
                end
                
                if sum(cellfun(@isempty,cur_dat(2:end))) > 0
                    person_there = 0;
                end
            end
            
            % decide what to do
            if person_there == 0 && ow == 1
                extract_anew = 1;
            elseif person_there == 0 && ow == 0
                extract_anew = 1;
            elseif person_there == 1 && ow == 1
                extract_anew = 0;
            else
                extract_anew = 0;
            end
            
        end
        
        if extract_anew == 1
            
            % phys data discarding
            try
                if ii > 1
                    % disp(['Trying to clear phys and ' ...
                    %    'P data of ' subs(ii-1).name])
                    clear phys
                    clear P
                    % disp('Success!')
                end
            catch
                % disp(['Could not clear phys and P of ' subs(ii-1).name])
            end
            
            % phys data reading
            cd(subs(ii).name)
            % OUT CAUSE FALSE NO-DATA FLAGS PRESENT! CHECK!!
            %         name_nophys = dir('no_phys_data*');
            %         if ~isempty(name_nophys)
            %             disp(['There was never any phys data to write to S: for ' ...
            %                 subs(ii).name])
            %             continue
            %         end
            
            name_phys = dir('phys_moved*');
            if ~isempty(name_phys)
                disp(['Now trying to read data of ' subs(ii).name])
                try
                    name_phys = name_phys(1).name;
                    tmpfid = fopen(name_phys);
                    tmp = textscan(tmpfid,'%s');
                    load(tmp{1}{1});
                    fclose(tmpfid);
                catch
                    disp(['Weirdly, no physio data found on S: for sub ' ...
                        subs(ii).name])
                    continue
                end
                name_P = dir('P_*');
                name_P = name_P(1).name;
                load(name_P)
            else
                disp(['No info on where physio data is on S: for sub ' ...
                    subs(ii).name])
                continue
            end
            
            % get the t(start(AI)) in seconds
            marker_start_script = find(phys.daten(:,1)>1,1,'first')/1000;
            t_start_AI          = P.t.start_script - marker_start_script;
            
            % get all the stimulus onsets, rts and cat vector
            if strcmp(desired_onset,'stim')
                t_stim = ((P.t.cur_trial.stim_on + P.t.start_exp) ...
                    - t_start_AI)*1000;
            elseif strcmp(desired_onset,'gamble')
                t_stim = ((P.t.cur_trial.stimLA_on + P.t.start_exp) ...
                    - t_start_AI)*1000;
            end
            cats   = P.cur.cat;
            rts    = P.cur.rt;
            
            % for channels 2:4
            for jj = 2:4
                % get the events
                dat = phys.daten(:,jj);
                cell_z=getevent(dat,pre,post,t_stim,rts,rt_end, ...
                    jj,post_eda_on,post_eda_off);
                
                % smoothing
                if do_smoothing
                    for kk = 1:length(cell_z)
                        try
                            cell_z{kk} = (movavg(cell_z{kk},lag,lag));
                        catch
                            warning('Failed smoothing!');
                        end
                    end
                end
                
                % get the mean reaction time series per cat
                % MUST BE REVISED SINCE WE HAVE DIFFERENT RTS
                % cell_z_mean(ii-1,:) = agk_mean_ts(cell_z,cats,
                % scale_opt,high_pass);
                
                % get the summary stat per trial
                % TODO: work directly with @fun for all functions
                if strcmp(trial_summary,'auc')
                    sum_fun = @mean;
                    cur_means = (agk_auc_per_trial(cell_z,scale_auc, ...
                        rts,high_pass,sum_fun))';
                elseif strcmp(trial_summary,'pmv')
                    cur_means = (agk_peakmaxvar_per_trial(cell_z, ...
                        scale_auc,rts,high_pass))';
                elseif strcmp(trial_summary,'max')
                    sum_fun = @max;
                    cur_means = (agk_auc_per_trial(cell_z,scale_auc, ...
                        rts,high_pass,sum_fun))';
                elseif strcmp(trial_summary,'median')
                    sum_fun = @median;
                    cur_means = (agk_auc_per_trial(cell_z,scale_auc, ...
                        rts,high_pass,sum_fun))';
                end
                
                % get the mean auc per cat (GRY GETS DISCARDED)
                tmp = agk_get_mn_auc(cur_means,cats,rts,high_pass);
                % only the first 4 categories (5th, gray, discarded!)
                tmp = tmp(1:4);
                mns_auc(ii,:) = tmp;
                
                % quality check: did we get the data without NANs?
                if  any(isnan(cur_means))
                    feedback_vector{jj} = ['nans in ' chn_nms{jj} ...
                        ' means produced'];
                else
                    feedback_vector{jj} = ['Ok. NO nans in ' chn_nms{jj} ...
                        ' means'];
                end
                subs(ii).error = feedback_vector;
                
                % get the auc per trial and the stim code and an id variable
                cur_aucs{ii,jj} = cur_means;
                stim{ii,jj}     = P.cur.stim';
                cur_sub{ii,jj}  = repmat(subs(ii).name,length(P.cur.stim),1);
                trial_ns{ii,1} = (1:length(P.cur.stim))';
                
                % change back to base dir
                cd(base_dir)
                
                % save the extracted data for later use
                data_cell{ii,jj}   = {cur_means,stim{ii,jj},cur_sub{ii,jj}, ...
                    trial_ns{ii,1}};
                [a,b] = fileparts(subs(ii).name);
                physio_data{ii,1}  = b;
                physio_data{ii,jj} = data_cell{ii,jj};
                save(['physio_data_' trial_summary '.mat'],'physio_data')
                
                % saving channelwise for later printing
                channelwise_data{1,jj} = {cur_aucs(:,jj), stim(:,jj), ...
                    cur_sub(:,jj), trial_ns};
            end
            
        else
            % get the data from already extracted data
            disp(['Subject ' b ' already extracted. Taking old data.'])
            
            % have to do it channel-wise
            for jj = 2:4
                % get the auc per trial and the stim code and an id variable
                cur_dat_extr   = cur_dat{jj};
                cur_aucs{ii,jj}   = cur_dat_extr{1};
                stim{ii,jj}       = cur_dat_extr{2};
                cur_sub{ii,jj}    = cur_dat_extr{3};
                trial_ns{ii,1}    = cur_dat_extr{4};
                
                % quality check: did we get the data without NANs?
                cur_means = cur_dat_extr{1};
                if  any(isnan(cur_means))
                    feedback_vector{jj} = ['nans in ' chn_nms{jj} ...
                        ' means produced'];
                else
                    feedback_vector{jj} = ['Ok. NO nans in ' chn_nms{jj} ...
                        ' means'];
                end
                subs(ii).error = feedback_vector;
                
                % change back to base dir
                cd(base_dir)
                
                % saving channelwise for later printing
                channelwise_data{1,jj} = {cur_aucs(:,jj), stim(:,jj), ...
                    cur_sub(:,jj), trial_ns};
            end
            
        end
    end
    
    %% print out the auc results: prep
    for jj = 2:4
        cd(base_dir)
        
        % get variables to print for this channel
        cur_aucs = channelwise_data{1,jj}{1};
        cur_stim = channelwise_data{1,jj}{2};
        cur_sub  = channelwise_data{1,jj}{3};
        trial_ns = channelwise_data{1,jj}{4};
        
        % reformatting and printing
        trial  = cell2mat(trial_ns);
        trial  = cellstr(num2str(trial));
        auc_v  = cell2mat(cur_aucs);
        for tt = 1:length(cur_sub)
            tmp = [];
            for ll = 1:size(cur_sub{tt},1)
                tmp_2 = cur_sub{tt}(ll,1:end);
                [d,f] = fileparts(tmp_2);
                tmp = [tmp;f];
            end
            cur_sub{tt} = tmp;
        end
        
        sub_v = [];
        for ii = 1: length(cur_sub)
            sub_v = [sub_v;agk_cellstr(cur_sub{ii})];
        end
        
        stim_v = [];
        for ii = 1:length(cur_stim)
            stim_v = [stim_v;cur_stim{ii}];
        end
        
        % reorganize and print
        disp(['Trying to write aggregated physio data to connection... ' ...
            chn_nms{jj} '_' trial_summary '_' desired_onset '.csv'])
        cur_cell = {};
        for ii = 1:length(stim_v)
            cur_cell{ii,1} = sub_v{ii};
            cur_cell{ii,2} = stim_v{ii};
            cur_cell{ii,3} = auc_v(ii);
            cur_cell{ii,4} = trial{ii};
        end
        cur_tab  = cell2table(cur_cell,'VariableNames',{'sub','stim', ...
            chn_nms{jj},'trial'});
        writetable(cur_tab,[chn_nms{jj} '_' trial_summary '_' desired_onset '.csv'])
    end
    
    % error reporting
    agk_physio_error_reporting(subs)
    agk_PDT_check_physio(physio_data,path_data)
end

%     % plot in one figure the mean time series with CI
%     hFig = figure(jj);
%     set(hFig, 'Position', [200 200 1300 800])
%     hold on
%     cur_colors = ['m','c','r','g','b'];
%     for ii = 1:size(cell_z_mean,2)
%         cur_mat = cell2mat(cell_z_mean(:,ii));
%         % take only every 10th sample
%         cur_ind = round(linspace(1,size(cur_mat,2)));
%         cur_mat = cur_mat(:,cur_ind);
%         cur_mns = mean(cur_mat);
%         cur_ci  = bootci(500,{@mean,cur_mat},'alpha',p_alpha);
%         % plot the CI area
%         new_ci = [(cur_ci(1,:)')*(1),cur_ci(2,:)'];
%         tmp_x = [1:length(cur_mns),fliplr(1:length(cur_mns))];
%         tmp_y = [new_ci(:,1)',fliplr(new_ci(:,2)')];
%         cur_m = plot(cur_mns,cur_colors(ii));
%         set(cur_m,'LineWidth',5)
%         cur_p = fill(tmp_x,tmp_y,cur_colors(ii));
%         if ii > 3
%             set(cur_p,'FaceColor','none')
%         end
%         set(cur_p,'EdgeColor',cur_colors(ii));
%     end
%     legend('gam','CIgam','neg','CIneg','pos','CIpos','neu','CIneu', ...
%     'gry','CIgry')
%     title([chn_nms{jj} ' post stim onset 3s time series, CI, ...
%     alpha = ' num2str(p_alpha)])
%     xlabel(gca,'time in ms')
%     ylabel(gca,'voltage (z-scores)')
%
%     % save plot
%     cd(resu_dir)
%     export_fig physio_report  -'pdf' -nocrop -append
%     cd(base_dir)
%
%     % plot in one figure the mean auc with CI per stim
%     cur_ci  = bootci(1000,{@mean,mns_auc},'alpha',p_alpha);
%     figure(jj + 10);
%     hold on
%     h = errorbar(1:size(mns_auc,2),mean(mns_auc),cur_ci(1,:), ...
%     cur_ci(2,:),'bx');
%     errorbarT(h,0.1,1)
%     % set the x-axis ticks and labels, set title
%     title([chn_nms{jj} ' post stim onset mean auc''s, CI, ...
%     alpha = ' num2str(p_alpha)])
%     set(gca,'XTick',1:length(cat_nms))
%     set(gca,'XTickLabel',cat_nms)
%     xlabel(gca,'category')
%     ylabel(gca,'mean auc')
%     line(0:(length(cat_nms)+1),zeros((length(cat_nms)+2),1))
%
%     % save the figure
%     cd(resu_dir)
%     export_fig physio_report_3  -'pdf' -nocrop -append
%     cd(base_dir)
