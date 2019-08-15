% calculates the payout based on the gambles

function P  = calc_payout(P)
% gambles which were not chosen
gam_yes = [P.cur.gamble(P.cur.choice == 1), P.cur.gamble(P.cur.choice == 2)];
% gambles which were not chosen
gam_not = [P.cur.gamble(P.cur.choice == 3), P.cur.gamble(P.cur.choice == 4), P.cur.gamble(P.cur.choice == 5)];

% first check whether there are at least P.min_gam gambles chosen
if P.min_gam > length(gam_yes)
    diskr = P.min_gam - (length(gam_yes));
    % which gambles from which to fill up?
    shuffled_gam_not = randperm(length(gam_not));
    ind_gam_not_for_fill = shuffled_gam_not(1:diskr);
    fill_up = gam_not(ind_gam_not_for_fill);
    gam_not_minus_fill = gam_not;
    gam_not_minus_fill(ind_gam_not_for_fill) = [];
    % new all_gam
    all_gam = [fill_up'; gam_yes'; gam_not_minus_fill'];
else
    all_gam = [gam_yes'; gam_not'];
end
%random sample of size P.sam
cur.ran = RandSample(1:length(all_gam),[P.sam,1]);
ran_gam = all_gam(cur.ran);

% play the gambles
allpay = 0;
for ll=1:length(ran_gam)
    % gambles will only be played when choice is 1 or 2
    if P.cur.choice(cur.ran(ll)) == 1 | P.cur.choice(cur.ran(ll)) == 2
        cur.gam = ran_gam{ll};
        % throw coin
        cur.res = randperm(2);
        if cur.res(1) ==1
            cur.pay = str2double(P.gain.strings(cur.gam(cur.res(1))));
        else
            cur.pay = str2double(P.loss.strings(cur.gam(cur.res(1))));
        end
        allpay(ll) = cur.pay-P.wager;
    else
        allpay(ll) = P.wager;
    end
end
P.final_payout = sum(allpay);
% disp(allpay)
% disp(P.final_payout)
% if P.final_payout > 34
%     P.final_payout = 29;
% elseif P.final_payout < 0
%     P.final_payout = 0;
% end

end