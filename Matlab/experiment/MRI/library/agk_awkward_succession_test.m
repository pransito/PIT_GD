% AWKWARD SUCCESSION ALTERNATIVE TEST
function result = agk_awkward_succession_test(P)

tmp.gmat.combs = P.gmat.combs(1:end,P.gmat.randp);
for ll = 2:length(tmp.gmat.combs)
    if tmp.gmat.combs(1:end,ll) == tmp.gmat.combs(1:end,ll-1)
        result = 0;
        return
    end
    % made it through all the tests
    result = 1;
end
if result == 1
    return
end


end