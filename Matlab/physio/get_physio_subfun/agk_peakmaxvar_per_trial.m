function cur_means = agk_peakmaxvar_per_trial(cell_z,scale_auc,rts,high_pass)
% takes the value where over all trials the variance in signal is highest
% e.g. variance of signal can be highest at 1228ms after onset, so we take
% value at this particular point on each trial
% often last trial is too short in length compared to others, so we leave
% it out and report there the ind_max_var based on n-1 trials if that ind
% is available, else the simple max

last_trial       = cell_z(end);
cell_z_mat       = cell2mat(cell_z(1:(end-1)))';
ind_max_var      = find(max(var(cell_z_mat))==var(cell_z_mat),1,'first');

cur_mat = [];
for ii = 1:size(cell_z_mat,1)
    try
        cur_mat(ii) = cell_z_mat(ii,ind_max_var);
    catch
        keyboard
    end
end

% add last trial
if length(last_trial{1}) >= ind_max_var
    cur_mat(ii+1) = last_trial{1}(ind_max_var);
else
    if isempty(max(last_trial{1}))
        warning('LAST TRIAL CANNOT COMPUTE MAX, RETURN NAN')
        cur_mat(ii+1) = NaN;
    else
        % if not accessible then report max
        last_trial_max_ind = find(max(last_trial{1}) == last_trial{1});
        cur_mat(ii+1) = max(last_trial{1});
    end
end

% prep scaling by cutting missings
cur_mat_pr= cur_mat(logical((rts < 4.5) .* (rts > high_pass)));

% scale
if scale_auc > 0
    if scale_auc == 1
        tmp_mn  = mean(cur_mat_pr);
        tmp_std = 1;
    elseif scale_auc == 2
        tmp_mn  = mean(cur_mat_pr);
        tmp_std = std(cur_mat_pr);
    end
    cur_means = (cur_mat-tmp_mn)/tmp_std;
else
    % no scaling
    cur_means = cur_mat;
end
end