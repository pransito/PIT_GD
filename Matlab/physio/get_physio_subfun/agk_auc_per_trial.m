function cur_means = agk_auc_per_trial(cell_z,scale_auc,rts,high_pass, ...
    sum_func)

% set an offset (e.g. 200 if you want to only start tallying 200ms after
% onset; minimum: 1
cur_onset = 1;

cur_mat   = [];
for ii = 1:length(cell_z)
    % we divide by length of cell_z because the rt's are different from
    % trial to trial; need a mean signal
    if isempty(cell_z{ii}(cur_onset:end)) && ii == length(cell_z)
        warning('CANNOT COMPUTE SUM_FUN IN LAST TRIAL')
        cur_mat(ii) = nan;
    else
        cur_mat(ii) = sum_func(cell_z{ii}(cur_onset:end));
    end
end

% prep scaling
% exclude rts that are too long or too short (high_pass)
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