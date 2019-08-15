% checking how many scans per session were used in PDT preprocessing and
% date of preprocessing
cur_home = pwd;
for kk = 1:length(all_subf)
        cur_sub = all_subf{kk};
        cd (cur_sub)
        cd MRT\NIFTI\
        disp(cur_sub)
        cur_fld = cellstr(ls());
        cur_fld(3:end)
        cd(cur_home)
end