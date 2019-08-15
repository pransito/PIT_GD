function ct = agk_mv_behav_data_subf_check_copy(ow,filename1,filename2,ct)

% check if target already there (only if overwrite not allowed)
if ow == 0
    filename_targ_PDT = fullfile(filename2,'PDT');
    filename_targ_SLM = fullfile(filename2,'SLM');
    if exist(filename_targ_PDT) || exist(filename_targ_SLM)
        disp(['Behav data in ' filename2 ' already copied'])
    else
        copyfile(filename1,filename2,'f');
        disp(['copied... ' filename1 ' to... '  filename2])
    end
else
    copyfile(filename1,filename2,'f');
    disp(['copied... ' filename1 ' to... '  filename2])
end
ct = ct + 1;