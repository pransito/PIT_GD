% check if ppi has run

cur_home  = 'L:\data';
cd(cur_home)
all_subs  = cellstr(ls('VPPG*'));
no_folder = {};
ct        = 0;
desired_folder = {'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Left_Accumbens'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Right_Accumbens'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Left_Amygdala'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Right_Amygdala'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Left_StrAso'; ...
    'MRT\NIFTI\PDT\results\PDT_ss_design_DEZ_us_orth_glc\PPI_Right_StrAso'};

for aa = 1:length(all_subs)
    for ff = 1:4
        cd(all_subs{aa})
        try
            cd(desired_folder{ff})
            cur_files = dir();
            cur_files(:).name
            %pause
        catch
            ct            = ct + 1;
            no_folder{ct,ff} = all_subs{aa};
        end
        cd(cur_home)
    end 
end