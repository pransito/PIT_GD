function out_cell = agk_basic_t_cons_hrf2(n)
% make one 1 contrast per conditions;
% here adds extra 0's for the hrf time and space derivative
out_cell = {};

out_cell{1} = 1;
for ii = 2:n
    out_cell{ii} = [zeros(1,length(out_cell{ii-1})),0,0,1];
end

end