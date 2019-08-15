% calculates from a trial vector, after which trial a break should occur
% v is a trial vector; length of which number of trials
% n is number of trials after which a break should occur

function [breaks] = agk_make_breaks(v,n)
v=length(v);
m=n;
test_break = n;
breaks = [];
count = 0;
while test_break < v
    count = count+1;
    breaks(count) = m;
    m = m+n;
    test_break = m;
end


end