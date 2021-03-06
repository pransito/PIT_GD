% script to extract picture onset score
function pic_scr_feedback = agk_get_pic_mri_scores(cur_sub,ss_name,cur_ROI)

disp([cur_sub ': Trying to extract.'])
success_message = [];

try
    % what is home path?
    cur_home = pwd;
    
    % get to the folder and load SPM
    cd(cur_sub)
    cd MRT\NIFTI\results
    cd(ss_name)
    load('SPM.mat')
    
    % 1 or 2 sessions?
    n_sess = length(SPM.Sess);
    
    % onsets
    ons_first = SPM.Sess(1).U(1).ons; % in s
    if (n_sess == 2)
        ons_scnd = SPM.Sess(2).U(1).ons; % in s
    end
    
    % get the model data
    cur_design = SPM.xX.X';
    if n_sess == 1
        pic_on_1 = cur_design(:,1);
    elseif n_sess == 2
        snd_con = (length(SPM.Sess(1).col)+6+1);
        pic_on_1 = cur_design(:,1);
        pic_on_2 = cur_design(:,snd_con);
    end
    
    % get the SPM for extraction
    path_SPM = [pwd '\SPM.mat'];
    [SPMp, xSPMp] = agk_make_result_spm(path_SPM, 1, 0.99, 1,0); % contrast number has to be the right one!
    cd ..
    cur_SPM   = SPMp;
    cur_xSPM  = xSPMp;
    cur_affix = 'picon';
    
    % where to save
    agk_mkdir_ex(pwd,'extr')
    cd('extr')
    
    % get some info on mask
    xY.spec = spm_vol(cur_ROI);
    
    % xY     - VOI structure
    % xY.xyz  = all_coord{ii}; % xY.xyz          - centre of VOI {mm}
    xY.Ic      = 0; % contrast used to adjust data (0 - no adjustment)
    xY.Sess    = 1; % session index
    xY.def     = 'mask';
    xY.xyz     = [0;0;0]; % sort of like a starting point to get to VOI (?)
    new_name_1 = 'picon_extr_s1';
    xY.name    = new_name_1;
    [Y, xY]    = spm_regions(cur_xSPM,cur_SPM,[],[xY]);
    save([xY.name '.mat'],'Y','xY');
    clearvars xY Y
    
    if n_sess == 2
        % get some info on mask
        xY.spec = spm_vol(cur_ROI);
        % xY     - VOI structure
        % xY.xyz  = all_coord{ii}; % xY.xyz          - centre of VOI {mm}
        xY.Ic   = 0; % contrast used to adjust data (0 - no adjustment)
        xY.Sess = 2; % session index
        xY.def  = 'mask';
        xY.xyz = [0;0;0]; % sort of like a starting point to get to VOI (?)
        new_name_2 = 'picon_extr_s2';
        xY.name  = new_name_2;
        [Y, xY]  = spm_regions(cur_xSPM,cur_SPM,[],[xY]);
        save([xY.name '.mat'],'Y','xY');
        clearvars xY Y
    end
    
    % interpolate Y_1 and Y_2 (the data)
    load([new_name_1 '.mat']);
    Y_1        = Y;
    data       = zscore(Y_1);
    v          = data;
    x          = (1:1:length(data))*2; % original coordinates of sampling
    xq         = linspace(x(1), x(end), (length(x)-1)*2000); % TR of 2s to 1000Hz, interpolated sampling points;
    Y_1        = interp1(x,v,xq);
    Y_1        = [Y_1 zeros(1,2000)]; % slice timing was to slice 1
    
    if n_sess == 2
        load([new_name_2 '.mat']);
        Y_2        = Y;
        data       = zscore(Y_2);
        v          = data;
        x          = (1:1:length(data))*2;
        xq         = linspace(1, length(data), (length(data)-1)*2000); % TR of 2s to 1000Hz
        Y_2        = interp1(x,v,xq);
        Y_2        = [Y_2 zeros(1,2000)]; % slice timing was to slice 1
    end
    
    % extract the pic snippets
    cur_l = 16; % seconds post onset to record BOLD
    for ii = 1:(length(ons_first))
        if ii == length(ons_first)
            try
                recorded_resp_1{ii,1} = Y_1(round(ons_first(ii)*1000):(round((ons_first(ii)+cur_l)*1000)-1));
            catch
                recorded_resp_1{ii,1} = Y_1(round(ons_first(ii)*1000):end);
            end
        else
            try
                recorded_resp_1{ii,1} = Y_1(round(ons_first(ii)*1000):(round((ons_first(ii)+cur_l)*1000)-1));
            catch
                recorded_resp_1{ii,1} = nan;
                success_message = 'subject had too few scans';
            end
        end
    end
    
    if n_sess == 2
        for ii = 1:(length(ons_scnd))
            if ii == length(ons_scnd)
                try
                    recorded_resp_2{ii,1} = Y_2(round(ons_scnd(ii)*1000):(round((ons_scnd(ii)+cur_l)*1000)-1));
                catch
                    recorded_resp_2{ii,1} = Y_2(round(ons_scnd(ii)*1000):end);
                end
            else
                try
                    recorded_resp_2{ii,1} = Y_2(round(ons_scnd(ii)*1000):(round((ons_scnd(ii)+cur_l)*1000)-1));
                catch
                    recorded_resp_2{ii,1} = nan;
                    success_message = 'subject had too few scans';
                end
            end
        end
        recorded_resp = [recorded_resp_1;recorded_resp_2];
    else
        recorded_resp = recorded_resp_1;
    end
    
    % get the mean per trial
    recorded_resp_m = [];
    for kk = 1:length(recorded_resp)
        recorded_resp_m(kk)= mean(recorded_resp{kk});
    end
    recorded_resp = recorded_resp_m';
    
    % get the trial and stim code
    cd (cur_home)
    cd (cur_sub)
    cd ('Behav\PDT')
    load(ls('P*'));
    trial  = (1:length(P.cur.choice))';
    stim   = P.cur.stim';
    choice = P.cur.choice;
    for kk = 1:length(stim)
        s              = stim(kk,:);
        s              = s{1};
        tmp            = regexp(s,'[.jpg]');
        s(tmp)         = [];
        new_stim{kk,1} = s;
    end
    stim = new_stim;
    
    % write the table
    [n,m] = fileparts(cur_ROI);
    s              = cellstr(m);
    roiname        = strrep(s,'_mask','');
    roiname        = roiname{1};
    outputname=['bold_scores_' roiname '.txt'];
    fileID=fopen(outputname,'wt');
    fprintf(fileID, 'trial\t');
    fprintf(fileID, 'stim\t');
    fprintf(fileID, 'bold\n');
    
    ct = 0;
    for ii=1:length(stim)
        if choice(ii) == 5
            continue
        end
        ct = ct + 1;
        cr_trial  = num2str(trial(ii));
        cr_stim   = stim{ii};
        cr_bold   = num2str(recorded_resp(ct));
        % In Datei schreiben
        fprintf(fileID, [cr_trial '\t' cr_stim '\t' cr_bold '\n']);
    end
    fclose(fileID);
    
    % feedback
    pic_scr_feedback = [cur_sub ': Successful. ' success_message];
    disp (pic_scr_feedback)
    
catch MExc
    disp([cur_sub ': Something went wrong.']);
    pic_scr_feedback = MExc;
    
end

end