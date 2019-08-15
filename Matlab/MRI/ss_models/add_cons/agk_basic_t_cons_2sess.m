function out_cell = agk_basic_t_cons_2sess(n,c)

out_cell = {};

for ii = 1:n
    out_cell{ii} = [[zeros(1,ii-1),1] [zeros(1,c-ii)] [zeros(1,6)] [zeros(1,ii-1),1] [zeros(1,c-ii)]];
end

end