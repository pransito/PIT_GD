function [ed] = calc_ed(gain, loss, Q1, Q2)
p      = [gain; loss; 0];
nenner = cross(Q2-Q1,p-Q1);
zaehler= Q2 - Q1;
ed     = nenner(3,:)/zaehler(1,:);
end