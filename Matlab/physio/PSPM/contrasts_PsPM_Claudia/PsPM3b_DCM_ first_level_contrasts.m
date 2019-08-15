%-----------------------------------------------------------------------
% Job saved on 01-Oct-2015 15:15:47 by cfg_util (rev $Rev: 701 $)
% pspm PsPM - Unknown
% cfg_basicio BasicIO - Unknown
% 28-07-2016
%--------------------------------
% ---------------------------------------
clear;


modelpath='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\DCM_firstlevel_fixed_responses';
datapath='S:\AG\AG-DFG-Juniorgroup\Data\Juniorgroup-02\Pavlov2_3dayfMRI\PREPdata\EDA\PsPMIn_DCM\input_2fixed_responses';

%for d=1:3
  %  modelpath= fullfile(mainpath, ['day', num2str(d)]);
    
    
    all_files = dir(fullfile(modelpath, 'DCM_*.mat'));
    

    % initialize PsPM
    scr_init;
    scr_jobman('initcfg');
    
    for p= 1:length(all_files)
        
        clear con*
      %%% ====== create contrasts ======= %%%%%%%%%%
      % load condition info for contrasts
      condfile=regexprep(    all_files(p).name, {'DCM_', '.mat.mat' }, {'', '_DATA.mat'});
      temp=load(fullfile(datapath, condfile));
      conds=temp.infod.conds;
      
    % (1) CS+ > CS-
    con1=conds;
    con1(con1==8)=-1; con1(con1~=-1)=1;
    
     % (2) unreinforced CS+ > CS-
    con2=conds;
    con2(con2==40)=0; con2(con2==4)=2; con2(con2==8)=-1;
     
       % (3) t1: CS+ > CS- 
    con3=conds;
    con3(61:end)=0; con3(con3==8)=-1; con3(con3>0)=1; 
    
     % (4) t2: CS+ > CS- 
    con4=conds;
    con4(1:60)=0; con4(con4==8)=-1; con4(con4>0)=1; 

     % (5) t1>t2: CS+ > CS- 
   % con5=[con3 + (con4*-1)];
    
   % (5) US >noUs
   con5=conds;
   con5(con5==40)=1; con5(con5==4)=-1; con5(con5==8)=0;
   
   % (6) US vs. baseline
    con6=conds;
    con6(con6==40)=3; con6(con6~=3)=-1; 

        clear matlabbatch
        
        
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.modelfile = {fullfile(modelpath,all_files(p).name)};
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.datatype = 'param';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(1).conname = 'CS+ > CS-';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(1).convec = con1';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(2).conname = 'unreinfCS+ > CS-';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(2).convec = con2';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(3).conname = 't1: CS+ > CS-';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(3).convec = con3';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(4).conname = 't2: CS+ > CS-';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(4).convec = con4';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(5).conname = 'US > noUS';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(5).convec = con5';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(6).conname = 'US > baseline';
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.con(6).convec = con6';
        
        
        matlabbatch{1}.pspm{1}.first_level{1}.contrast.deletecon = true;
        
        % run batch
        scr_jobman('run', matlabbatch)
        
    end
    
%end

