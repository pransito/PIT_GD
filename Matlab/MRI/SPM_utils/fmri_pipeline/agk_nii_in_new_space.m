function agk_nii_in_new_space(reference,name_orig, name_out)
for ii = 1:length(name_orig)
    cur_im_struct{1} = reference;
    cur_im_struct{2} = name_orig{ii};
    f = 'i2';
    spm_imcalc(cur_im_struct,name_out{ii},f,{0});
end

end