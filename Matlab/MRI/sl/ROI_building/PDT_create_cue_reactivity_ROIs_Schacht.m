% create sphere images for cue reactivity contrasts
cur_spm  = 'E:\Daten\VPPG\MRT\MRT\VPPG0209\MRT\NIFTI\results\PDT_ss_design_ed_03\SPM.mat';
all_vois = {[-6 -36 26];[-52 10 -14];[34 -74 36];[-12 -58 26]};
all_labs = {'L_pos_cing','L_sup_temp','R_precuneus','L_precuneus'};

for vv = 1:length(all_vois)
    create_sphere_image(cur_spm,{all_vois{vv}},{all_labs{vv}},8)
end