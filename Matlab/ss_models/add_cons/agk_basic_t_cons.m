function out_cell = agk_basic_t_cons(n)

out_cell = {};

for ii = 1:n
    out_cell{ii} = [zeros(1,ii-1),1];
end

end