%-----------------------------------------------------------------------
% Job saved on 01-Oct-2015 15:15:47 by cfg_util (rev $Rev: 701 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
%-----------------------------------------------------------------------
clear;

mainpath='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata_d1_allExperiments\EDA\PsPM_GLM_In';

%% select sample: based on R preprocessing, see script:
%% C:\Dokumente und Einstellungen\gaehlsdc\Desktop\Bitbucket_repos\kitchen3\scripts\0_prepare_eda_data.R 
%% and participant flowchart EDA
% exlude subjects:
%exclude{1,1}={'10' '22' '28' '29' '31' '36'}
%exclude{1,2}={ '11' '36'};
%exclude{1,3}={ '1'  '3'  '5'  '8'  '9' '10' '13' '21' '22' '23' '27' '29' '30' '33' '35'};


for d=3
    modelpath= fullfile(mainpath, ['day', num2str(d)], 'first5trials_combined\1st_level_glm');
    
    
    all_files = dir(fullfile(modelpath, 'glm_*.mat'));
    
  %  data_files={};
   % for i=1:length(all_files)
        
  %      if sum(~cellfun('isempty',regexp(all_files(i).name, exclude{d})))==0
 %           data_files(end+1)={all_files(i).name}
 %       end
 %   end
    
    % initialize PsPM
    scr_init;
    scr_jobman('initcfg');
    
    for p= 1:length(all_files)
        
        clear matlabbatch
        
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.modelfile = {fullfile(modelpath,all_files(p).name)};
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.datatype = 'cond';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con.conname = 'first CS+ > CS-';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con.convec = [1 0 -1 0 0];
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.deletecon = true;
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.zscored = false;
        
        % run batch
        scr_jobman('run', matlabbatch)
        
    end
    
end
