function cell_out = getevent(dat,pre,post,onsets,rts,rt_end,jj,post_eda_on,post_eda_off)

for ii = 1:length(onsets)
    cur_onset = round(onsets(ii));
    if jj == 2 % in case it's eda
        old_onset = cur_onset;
        cur_onset = old_onset + post_eda_on;
        cur_offset= old_onset + post_eda_off;
    end
    
    try 
        blt= dat((cur_onset-pre):cur_onset,1);
        bl = median(blt);
    catch
        if ii == length(onsets)
            warning('TRUNCATED DATA FOR BASELINE COMPUTATION')
            blt= dat((cur_onset-pre):end,1);
            bl = median(blt);
        else
            error('cannot compute baseline although not last trial')
        end
    end
    
    if rts(ii) > 4 || jj == 2 % in case it is eda
        if jj ~=2
            % take a default length, if this was a missing
            cell_out{ii} = dat(cur_onset:(cur_onset+post))-bl;
        else
            % if eda
            try
                cell_out{ii} = dat(cur_onset:cur_offset)-bl;
            catch
                if ii == length(onsets)
                    cell_out{ii} = dat(cur_onset:end)-bl;
                else
                    rethrow(lasterror)
                    disp('EDA extraction failed')
                    return
                end
            end
        end
    else
        if rt_end
            % only take time until reaction
            cell_out{ii} = dat(cur_onset:(cur_onset+round(rts(ii)*1000)))-bl;
        else
            try
                cell_out{ii} = dat(cur_onset:(cur_onset+round(post)))-bl;
            catch
                if ii == length(onsets)
                    warning('TRUNCATED DATA FOR MEAN COMPUTATION')
                    cell_out{ii} = dat(cur_onset:end)-bl;
                else
                    error('cannot compute mean of this trial')
                end
            end
        end
    end
end