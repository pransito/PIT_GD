% takes in a cell with time serieses
% and a vector indicating the categories
% computes mean time series
% scales (if scale), but without centering
% (because the data is already set to a individual baseline) 
% different from AUC measurement where we also center;

function cell_mean = agk_mean_ts(cell_z,cats,scale_opt,rts,high_pass)
u_cats = unique(cats);
% prep scaling
if scale_opt > 0
    cur_mat   = (cell2mat(cell_z))';
    % for calc of std and mean, take out missings and rts under 2.0s
    cur_mat_pr= cur_mat(((rts < 4.5) .* (rts > high_pass)),:);
    cur_stds  = std(cur_mat_pr) ;
    cur_mns   = mean(cur_mat_pr);
end

for ii = 1:length(u_cats)
    cur_cells = cell_z(cats==u_cats(ii));
    cur_mat   = (cell2mat(cur_cells))';
    % scaling
    if scale_opt == 1
        cur_mat = agk_scale(cur_mat,cur_stds,zeros(size(cur_mat,2)));
    end
    
    if scale_opt == 2
        cur_mat = agk_scale(cur_mat,cur_stds,cur_mns);
    end
    cur_mean  = mean(cur_mat);
    cell_mean{ii} = cur_mean;
end
end