%% calc payout as instructed in BGG study
% 5 gambles out of all gambles which were rated as "yes surely"
function P = calc_payout_BGG(P)
% sorting gambles by rating and shuffling them
tmp.all_chosen_gambles = {};
for ii = 1:P.gmat.n_cond
    tmp.chosen_gambles_byrating{ii} = P.cur.gamble(P.cur.choice==ii);
    tmp.chosen_gambles_byrating{ii} = tmp.chosen_gambles_byrating{ii}(randperm(length(tmp.chosen_gambles_byrating{ii})));
    if ~isempty(tmp.chosen_gambles_byrating{ii})
        tmp.all_chosen_gambles = [tmp.all_chosen_gambles, tmp.chosen_gambles_byrating{ii}];
    end
end

% pick the min_gam and shuffle
tmp.min_gam = tmp.all_chosen_gambles(1:P.min_gam);
tmp.min_gam = tmp.min_gam(randperm(length(tmp.min_gam)));

% now play the gambles; we play 
for ii = 1:P.sam
    % gain or loss?
    tmp.result = randperm(length(tmp.all_chosen_gambles{ii}));
    tmp.result = tmp.result(1);
    if tmp.result == 1
        tmp.result = str2num(P.gain.strings{tmp.all_chosen_gambles{ii}(1)});
    else
        tmp.result = str2num(P.loss.strings{tmp.all_chosen_gambles{ii}(2)});
    end
    tmp.gamble_results(ii) = tmp.result;
end

P.final_payout = sum(tmp.gamble_results);

end