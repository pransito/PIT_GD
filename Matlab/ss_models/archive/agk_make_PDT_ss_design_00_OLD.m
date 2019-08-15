% agk_make_PDT_ss_design
% for one subject
% makes the ss design of the PDT task based on the Tom et al. (2007) paper
% pictures here are put in as categorical vectors
% to allow a cue reactivity contrast (between categories modeling)

% INPUT
% cur_sub      : name of current subject
% which_folders: name of folder with niftis of task (first will be picked)
% aggr         : aggregation level gambling matrix (we usually take 3)
% run_it       : should the job run? (will be only save if not)
% acc_rec      : should accept be included as a factor in model (def: no)
% expl_mask    : usually use a gray matter mask here
% cur_tmpl     : the ss job template to be used here, cell, first field is
%                the one without accept reject as factor and second with

% OUTPUT
% error_message: success message or explanation what hasn't worked

% IMPLICIT OUTPUT
% writes the ss model into the results_ssdir in the subject folder

% THIS MODEL ('PDT_ss_design_00')
% 4 task on: PIC, PIC+GAM, PIC+GAM+OPT, FEEDBACK
% 3 param modulators in PIC: category dummy coded (gam, neg, neu)
% 6 param mod in all others: gain, abs(loss), ed; cat dummy coded

% DETAILS
% preproc_job is needed to get the slice timing parameters
% (to create time bins), will be looked for in the nifti folder provided
% will look for "preprocessing..." pattern
% abs values of losses are used
% nifti data need to be SPM12 preprocessed
% takes in an aggregation factor: e.g. 1 means no change; 2 means, the 12
% by 12 matrix will be aggregated to a 6-by-6 matrix, and so on
% the picture category is modeled by three dummy variables (i.e. all 0 is
% neutral)

% AUTHORSHIP
% author: Alexander Genauck
% date  : 24.03.2016
% email : alexander.genauck@charite.de

function error_message = agk_make_PDT_ss_design_01(cur_sub,cur_tmpl,aggr, ...
    run_it,acc_rec,expl_mask)
%% PREPARATIONS
% change into subs directory
root_dir = pwd;
cd(cur_sub)

% name of this analysis determines the results directory
results_ssdir = 'PDT_ss_design_01';

% gain and loss ranges
gain_min = 14;
gain_max = 36;
loss_max = 18;
loss_min = 7;

% for euclidean distance
vec = [2;1;0];   % slope vector [gain; loss; 0]
sp  = [26;13;0]; % sp support point; point on the diagonal [gain; loss; 0]

% for microtime resolution
load(ls('Preprocessing*'));
preproc_job = matlabbatch;
cur_nslices   = preproc_job{1}.spm.temporal.st.nslices;
cur_refslice  = preproc_job{1}.spm.temporal.st.refslice;

% calculate the aggregated possible values
cur_gains = (gain_min:2:gain_max);
cur_losss = loss_min:loss_max    ;
[vg,osg,nsg]  = agk_downsample_steps(cur_gains,aggr);
gain_min  = min(vg);
gain_max  = max(vg);
[vl,osl,nsl]  = agk_downsample_steps(cur_losss,aggr);
loss_min  = min(vl);
loss_max  = max(vl);

% load template
if acc_rec
    load(cur_tmpl{2})
else
    load(cur_tmpl{1})
end

%% FILLING BATCH
if acc_rec == 0
    names     = {'Pic.on','Pic.gam.on','Pic.gam.opt.on','feedback'};
    onsets    = cell(1,4);
    durations = cell(1,4);
elseif acc_rec == 1
    % needs to be adjusted later !
    names = {'accepted' 'rejected'};
    onsets = cell(1,2);
    durations = cell(1,2);
end

pmod = struct('name',{},'poly',{},'param',{});
for ii = 1:numel(names)
    pmod(ii).name{1} = 'gam';
    pmod(ii).poly{1} = 1;
    pmod(ii).name{2} = 'neg';
    pmod(ii).poly{2} = 1;
    pmod(ii).name{3} = 'pos';
    pmod(ii).poly{3} = 1;
    pmod(ii).name{4} = 'gain';
    pmod(ii).poly{4} = 1;
    pmod(ii).name{5} = 'loss';
    pmod(ii).poly{5} = 1;
    pmod(ii).name{6} = 'ed';
    pmod(ii).poly{6} = 1;
end

% get behav data
behav_data = 0;
try
    cd('Behav\PDT')
    load(ls('P*'))
    behav_data = 1;
catch
    behav_data = 0;
end

% prep the param mod regressors for each task_on regressor
% for pic on
p11 = []; % gam
p12 = []; % neg
p13 = []; % neu
% for pic and gamble on
p21 = []; % gain
p22 = []; % loss
p23 = []; % ed
p24 = []; % gam
p25 = []; % neg
p26 = []; % neu
% for pic and gamble and options on
p31 = []; % gain
p32 = []; % loss
p33 = []; % ed
p34 = []; % gam
p35 = []; % neg
p36 = []; % neu
% for feedback (missings will be discarded anyways)
p41 = []; % gain
p42 = []; % loss
p43 = []; % ed
p44 = []; % gam
p45 = []; % neg
p46 = []; % neu

if acc_rec == 1
    % needs to be reviewed still
    p21 = [];
    p22 = [];
    p23 = [];
end

%% getting the param modulators split by acc_rec or not
if behav_data == 1
    if acc_rec == 0
        for ii = 1 : length(P.cur.choice)
            if P.cur.choice(ii) > 0 && P.cur.choice(ii) < 5
                % PIC ON
                onsets(1)    = {[cell2mat(onsets(1)) P.t.cur_trial.stim_on(ii)]};
                durations(1) = {[cell2mat(durations(1)) (P.t.cur_trial.stimLA_watch(ii) - P.t.cur_trial.stim_on(ii))]};
                switch P.cur.cat
                    case 1
                        cur_gam = 1;
                        cur_neg = 0;
                        cur_pos = 0;
                    case 2
                        cur_gam = 0;
                        cur_neg = 1;
                        cur_pos = 0;
                    case 3
                        cur_gam = 0;
                        cur_neg = 0;
                        cur_pos = 1;
                    case 6
                        cur_gam = 0;
                        cur_neg = 0;
                        cur_pos = 0;
                end
                % pic dummy code
                p11          = [p11 cur_gam];
                p12          = [p12 cur_neg];
                p13          = [p13 cur_pos];
                
                % PIC PLUS GAMBLE ON
                onsets(2)    = {[cell2mat(onsets(2)) P.t.cur_trial.stimLA_watch(ii)]};
                durations(2) = {[cell2mat(durations(2)) (P.t.cur_trial.stimLA_on(ii) - P.t.cur_trial.stimLA_watch(ii))]};
                % gain
                cur_gain     = agk_recode(str2double(cell2mat(P.gain.strings(P.cur.gamble{ii}(1)))),osg,nsg);
                p21          = [p21 cur_gain];
                % loss (here changed loss to abs. loss)
                cur_loss     = agk_recode(abs(str2double(cell2mat(P.loss.strings(P.cur.gamble{ii}(2))))),osg,nsg);
                p22          = [p22 cur_loss];
                % ed
                cur_point    = [cur_gain;cur_loss;0];
                ed           = agk_get_ed(cur_point,sp,vec);
                p23          = [p23 ed];
                % pic dummy code
                p24          = [p24 cur_gam];
                p25          = [p25 cur_neg];
                p26          = [p26 cur_pos];
               
                % PIC PLUS GAMBLE ON PLUS OPTIONS ON
                onsets(3)    = {[cell2mat(onsets(3)) P.t.cur_trial.stimLA_on(ii)]};
                durations(3) = {[cell2mat(durations(3)) (P.t.cur_trial.stimLA_off(ii) - P.t.cur_trial.stimLA_on(ii))]}; % or use: P.cur.rt(ii)
                % gain, abs. loss, ed
                p31          = [p31 cur_gain];
                p32          = [p32 cur_loss];
                p33          = [p33 ed];
                % pic dummy code
                p34          = [p34 cur_gam];
                p35          = [p35 cur_neg];
                p36          = [p36 cur_pos];
                
                % FEEDBACK
                onsets(4)    = {[cell2mat(onsets(4)) P.t.cur_trial.stimLA_off(ii)]};
                durations(4) = {[cell2mat(durations(4)) P.instr.slow.time]};
                % gain, abs. loss, ed
                p41          = [p41 cur_gain];
                p42          = [p42 cur_loss];
                p43          = [p43 ed];
                % pic dummy code
                p44          = [p44 cur_gam];
                p45          = [p45 cur_neg];
                p46          = [p46 cur_pos];
            end
        end
    else
        % this still needs to be revised!
        for ii = 1 : size(d.data,1)
            P = [d.data(ii,1);d.data(ii,2);0];
            if d.data(ii,4) < 3
                onsets(1) = {[cell2mat(onsets(1)) d.data(ii,3)*oscorrf]};
                durations(1) = {[cell2mat(durations(1)) d.data(ii,5)]};
                % gain
                p11 = [p11 agk_recode(d.data(ii,1),osg,nsg)];
                %loss
                p12 = [p12 agk_recode(abs(d.data(ii,2)),osl,nsl)];
                ed = agk_get_ed(cur_point,sp,vec);
                p13 = [p13 ed];
            end
            if d.data(ii,4) > 2 && d.data(ii,4) < 5
                onsets(2) = {[cell2mat(onsets(2)) d.data(ii,3)*oscorrf]};
                durations(2) = {[cell2mat(durations(2)) d.data(ii,5)]};
                % gain
                p21 = [p21 agk_recode(d.data(ii,1),osg,nsg)];
                % loss
                p22 = [p22 agk_recode(d.data(ii,2),osg,nsg)];
                ed = agk_get_ed(cur_point,sp,vec);
                p23 = [p23 ed];
            end
        end
    end
    
    if acc_rec == 0
        pmod(1).param{1} = p11;
        pmod(1).param{2} = p12;
        pmod(1).param{3} = p13;
        
        pmod(2).param{1} = p21;
        pmod(2).param{2} = p22;
        pmod(2).param{3} = p23;
        pmod(2).param{4} = p24;
        pmod(2).param{5} = p25;
        pmod(2).param{6} = p26;
        
        pmod(3).param{1} = p31;
        pmod(3).param{2} = p32;
        pmod(3).param{3} = p33;
        pmod(3).param{4} = p34;
        pmod(3).param{5} = p35;
        pmod(3).param{6} = p36;
        
        pmod(4).param{1} = p41;
        pmod(4).param{2} = p42;
        pmod(4).param{3} = p43;
        pmod(4).param{4} = p44;
        pmod(4).param{5} = p45;
        pmod(4).param{6} = p46;
    elseif acc_rec == 1
        % this still needs to be revised
        pmod(2).param{1} = p21;
        pmod(2).param{2} = p22;
        pmod(2).param{3} = p23;
    end
end

% get the EPIs of this subject
cd(root_dir)
cd(cur_sub)
cd('MRT\NIFTI');
found_epi = 0;
cur_epi_dirs  = cellstr(ls('*_epi*'));
cur_MoCo_dirs = cellstr(ls('*_MoCo*'));
if length(cur_epi_dirs) > 0 % check if we're working with epis
    cd(cur_epi_dirs{1})     % PDT task is first EPI run
elseif length(cur_MoCo_dirs)% check if we're working with MoCo
    cd(cur_MoCo_dirs{1})    % PDT task is first EPI run 
end

found_epi = 1;
matlabbatch{1}.spm.stats.fmri_spec.sess.scans = cellstr(spm_select('FPList',pwd,'swuaepi'));
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = [];
matlabbatch{1}.spm.stats.fmri_spec.sess.multi_reg = cellstr(spm_select('FPList',pwd,'^rp'));

if found_epi == 0 % incase no scans were found: throw away
    matlabbatch{1}.spm.stats.fmri_spec.sess.scans = {''};
end

cd .. % go back to NIFTI folder

% create the results dir
mkdir(pwd,'results')
if exist([pwd filesep results_ssdir])
    cmd_rmdir([pwd filesep results_ssdir])
end
agk_mkdir_ex(pwd,results_ssdir)
cd(results_ssdir)

matlabbatch{1}.spm.stats.fmri_spec.dir = cellstr(pwd);
if behav_data == 1
    save('mult_cond.mat','names','onsets','durations','pmod');
    matlabbatch{1}.spm.stats.fmri_spec.sess.multi = cellstr(spm_select('FPList',pwd,'mult_cond.mat'));
end

% fill in microtime resolution
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t  = cur_nslices;
matlabbatch{1}.spm.stats.fmri_spec.timing.fmri_t0 = cur_refslice;
% specifiy an explicit mask, which voxels shall only be analysed
matlabbatch{1}.spm.stats.fmri_spec.mask = cellstr(expl_mask);

if behav_data == 1
    save('design.mat','matlabbatch');
end
try
    if run_it == 1
        spm_jobman('run',matlabbatch);
    end
catch MExc
    fct = fct +1;
    disp(['...failed: ' deblank(base_dirs(zz,:))])
    failed_subs{fct} = deblank(base_dirs(zz,:));
    disp (MExc.message)
end
cd(root_dir);


end