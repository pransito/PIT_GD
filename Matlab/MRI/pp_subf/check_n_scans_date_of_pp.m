% checking how many scans per session were used in PDT preprocessing and
% date of preprocessing

cur_home = pwd;
for kk = 1:17
    try
        cur_sub = all_subf{kk};
        cd (cur_sub)
        cd MRT\NIFTI\
        cur_fld = cellstr(ls());
        
        res     = strfind(cur_fld,'MoCo');
        res_epi = strfind(cur_fld,'epi');
        
        cur_res = [];
        for jj = 1:length(res)
            cur_res(jj) = ~isempty(res{jj});
        end
        mocos = cur_fld(logical(cur_res));
        
        cur_res = [];
        for jj = 1:length(res_epi)
            cur_res(jj) = ~isempty(res_epi{jj});
        end
        epis = cur_fld(logical(cur_res));
        
        if ~isempty(epis)
            pdt_series = epis(1);
        else
            pdt_series = mocos(1);
        end
        
        cd(pdt_series{1})
        
        %displaying
        cur_sub

        load(ls('preprocessing*'))
        matlabbatch{1}.spm.temporal.st.scans
        
        % display date of swuaf
        cur_swuaf = cellstr(ls('swua*'));
        fileinfo  = dir(cur_swuaf{1})
        
        cd(cur_home)
    catch
        disp (['Problem with subject: ' cur_sub]) 
        cd(cur_home)
        
    end
    
end