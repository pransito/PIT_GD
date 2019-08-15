function [ok] = test_randperm(param_vec, cond_vec, alpha_1, alpha_2)

% test for significant mean difference
if anovan(param_vec,cond_vec,'display','off') < alpha_1
    ok = 0;
    return
end
if kruskalwallis(param_vec,cond_vec,'off') < alpha_1
    ok = 0;
    return
end
%homogenity of variance
if levenetest([param_vec',cond_vec]) < alpha_2
    ok = 0;
    return
end
ok = 1;
end