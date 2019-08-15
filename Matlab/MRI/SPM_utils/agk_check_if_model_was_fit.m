% check which models have not been esimtated
cur_pwd = 'F:\AG_Diplomarbeit\Preprocessed_on_Windows_Machine_swuaf_VBM8\results_2nd_level\gPPI\ep2d_bold_LA_00';
cd(cur_pwd)
all_paths = genpath(cur_pwd);
all_paths = strsplit(all_paths,';');
unf_paths = {};
ct = 0;

for ii = 1:(length(all_paths)-1)
    cur_path = all_paths{ii};
    cd(cur_path)
    d = cellstr(ls());
    if ~isempty(strmatch('SPM.mat',d))
        d = cellstr(ls());
        if isempty(strmatch('con_0001.nii',d))
            disp('unfit model found!')
            ct = ct + 1;
            unf_paths{ct} = pwd; 
        else
            disp('model was fit!')
        end
    else
        continue
    end
end

% now try fitting again
disp('TRYING TO FFIT UNFIT MODELS')
still_unf = {};
ct = 0;
for ii = 1:length(unf_paths)
    cd(unf_paths{ii})
    load('gPPI.mat')
    try
        spm_jobman('initcfg')
        spm_jobman('run',matlabbatch)
    catch
        ct = ct + 1;
        still_unf{ct} = pwd;
    end
end