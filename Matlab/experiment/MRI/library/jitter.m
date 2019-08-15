function [vec] = jitter(jmin,jmax,n)
tmp   = [];
count = 0;
% first while loop just measures how many steps from min to max we can take
while length(tmp) < n
    count = count + 1;
    tmp = [tmp;repmat(jmin,round(n/2^count),1)];     
end

values = linspace(jmin,jmax,count);
tmp    = [];
for ii = 1:length(values)
    tmp = [tmp;repmat(values(ii),round(n/2^ii),1)]; 
end
vec = tmp;