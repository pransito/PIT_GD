% script to delete some stuff
root     = 'F:\data';
pattern  = 'PDT_ss_design_DEZ_hrf2*';

% search and destroy
cd(root)
allSubf = cellstr(ls('VPPG*'));

for ii = 1:length(allSubf)
    cd(root)
    ii
    cd(allSubf{ii})
    cd('MRT\NIFTI\PDT\results')
    toDel = cellstr(ls(pattern));
    if ~isempty(toDel)
        for dd = 1:length(toDel)
            cur_dir = fullfile(pwd,toDel{dd});
            cur_cmd = ['rmdir /S /Q ' cur_dir];
            feedback = system(cur_cmd);
            disp(feedback);
        end
    end
    
end

