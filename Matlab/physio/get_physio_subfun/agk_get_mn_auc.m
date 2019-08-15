function [mns_auc] = agk_get_mn_auc(cur_means,cats,rts,high_pass)

cur_means_pr = cur_means(logical((rts < 4.5) .* (rts > high_pass)));
cats_pr      = cats(logical((rts < 4.5) .* (rts > high_pass)));

u_cats = unique(cats);

for ii = 1:length(u_cats)
    tmp_means = cur_means_pr(cats_pr==u_cats(ii));
    mns_auc(ii)   = mean(tmp_means);
end

end