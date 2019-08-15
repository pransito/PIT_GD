function agk_mask_nii(inp,mask)
for ii = 1:length(inp)
    cur_im_struct{1} = mask;
    cur_im_struct{2} = inp{ii};
    f = 'i1.*i2';
    spm_imcalc(cur_im_struct,['masked_' inp{ii}],f,{0})
end

end