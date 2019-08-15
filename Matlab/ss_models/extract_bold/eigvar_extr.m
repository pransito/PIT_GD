 % get a SPM to have handle on betas
    cur_pSPM_gain ='F:\AG_Diplomarbeit\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\gPPI\ep2d_bold_LA_00\PPI_DRN_mask_cond\nocov\con_PPI_loss_BGG\3_noacc\SPM.mat';
    cur_pSPM_loss ='F:\AG_Diplomarbeit\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\gPPI\ep2d_bold_LA_00\PPI_Left_MFG middle frontal gyrus_-40  39  23_mask_cond\nocov\con_PPI_loss_BGG\3_noacc\SPM.mat';
    [SPMg, xSPMg] = agk_make_result_spm(cur_pSPM_gain, 1, 0.99, 1,0);
    if cur_analysis == 'gPPI'
        [SPMl, xSPMl] = agk_make_result_spm(cur_pSPM_loss, 1, 0.99, 1,0); % contrast number has to be the right one!
    else
        [SPMl, xSPMl] = agk_make_result_spm(cur_pSPM_loss, 2, 0.99, 1,0);
    end
    
    % where to save
    cd(sd_base_dir)
    cur_dir = ['sig_res_' num2str(addon.aggr) '_' addon.acc];
    agk_mkdir_ex(pwd,'sig_results')
    cd('sig_results')
    agk_mkdir_ex(pwd,cur_dir)
    cd(cur_dir)
    agk_mkdir_ex(pwd,cur_analysis)
    cd(cur_analysis)
    agk_mkdir_ex(pwd,'eigenvariates')
    cd('eigenvariates')
    
    extr_ct =0;
    for ii = 1:length(all_coord)
        % if it is with cov we'll skip
        if isempty(strfind(all_names{ii},'_nocov_'))
            disp('IAM SKIPPING CAUSE IT IS WITH COV')
            continue
        end
        all_names_pruned = [all_names_pruned; all_names(ii)];
        
        if ~isempty(strfind(all_names{ii},'gain'))
            continue % leave out gain here
            cur_SPM   = SPMg;
            cur_xSPM  = xSPMg;
            cur_affix ='gn';
        else
            cur_SPM   = SPMl;
            cur_xSPM  = xSPMl;
            cur_affix ='ls';
        end
        
        % get eigenvariate
        % xY     - VOI structure
        
        % xY.xyz  = all_coord{ii}; % xY.xyz          - centre of VOI {mm}
        xY.Ic   = 0; % contrast used to adjust data (0 - no adjustment)
        xY.Sess = 1; % extract from which session?
        xY.def  = 'sphere';
        % size of sphere
        xY.spec = 1;
        %       xY.str          - VOI description as a string
        xY.XYZmm = [1;1;1];    %- Co-ordinates of VOI voxels {mm}
        %       xY.y            - [whitened and filtered] voxel-wise data
        %       xY.u            - first eigenvariate {scaled - c.f. mean response}
        %       xY.v            - first eigenimage
        %       xY.s            - eigenvalues
        %       xY.X0           - [whitened] confounds (including drift terms)
        
        cur_name = [num2str(all_coord{ii}') '_' all_labels{ii}(1:10) '.mat'];
        cur_name = strrep(cur_name,'-','neg');
        % rm excess white space
        cur_name = regexprep(cur_name,'\s+','_');
        tmp_name = textscan(cur_name,'%s','delimiter','_');
        new_name = [];
        for ll = 1:3
            new_name =[new_name,tmp_name{1}{ll} '_'];
        end
        new_name = [new_name,cell2mat(tmp_name{1}(4:end)')];
        new_name = [num2str(ii) '_' new_name '_' cur_affix];
        xY.name  = new_name;
        
        % save that name
        all_fnames = [all_fnames;cellstr(new_name)];
        
        [Y, xY]  = spm_regions(cur_xSPM,cur_SPM,[],[xY]);
        clearvars cur_SPM cur_xSPM
        
        if exist([new_name '.mat'],'file')
            if exist([new_name '_2' '.mat'],'file')
                save([new_name '_3' '.mat'],'Y','xY')
            else
                save([new_name '_2' '.mat'],'Y','xY')
            end
        else
            save([new_name '.mat'],'Y','xY')
        end
        
        
        % make sure vars won't be used again
        clearvars Y xY
    end
    
    cur_eigv = cellstr(ls('*.mat'));
    cur_eigv = cur_eigv(1:end);
    
    name_line = [];
    eigv_mat  = [];
    for ii = 1:length(cur_eigv)
        load(cur_eigv{ii})
        name_line = [name_line, cellstr(xY.name)];
        eigv_mat(1:length(xY.y),ii) = xY.y;
    end
    
    % write to file
    agk_mkdir_ex(pwd,'export')
    cd('export')
    fid = fopen('eigv_export.dat','wt');
    form_spec = [];
    for ii = 1:(length(name_line)-1)
        form_spec = [form_spec, '%s\t'];
    end
    form_spec = [form_spec '%s'];
    fprintf(fid,form_spec,name_line{1:end});
    fprintf(fid,'\n');
    fclose(fid)
    dlmwrite('eigv_export.dat',eigv_mat,'-append','delimiter','\t')
    close all