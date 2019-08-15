cur_l = 800;

% in the first run
figure(7)
model = zscore(pic_ono_1(1:length(Y_1)));
plot(model)
hold on
data = zscore(Y_1(1:end));
plot(data,'r-')
[r,p] = corr(model,data)
figure(9); plot(model,data,'.')

% in the second run
figure(8)
model = zscore(pic_ono_2((length(Y_1)+1):(length(Y_1)+cur_l)));
plot(model)
hold on
data = zscore(Y_2(1:cur_l));
plot(data,'r-')
[r,p] = corr(model,data)

% onsets of pic on in 1st run
ons_first = SPM.Sess(1).U(1).ons; % in s
dur_first = SPM.Sess(1).U(1).dur; % in s

% interpolate timeseries
v          = data(1:length(data));
x          = 1:1:length(data);
xq         = linspace(1, length(data), 816*2000);
vektorlang = interp1(x,v,xq); 

figure(10)
plot(x,v,'-')
hold on
plot(xq,vektorlang,'r-')

% extract the pic snippets
cur_l = 20;
mean_response = vektorlang(round(ons_first(1)*1000):round((ons_first(1)+cur_l)*1000));
for ii = 2:(length(ons_first)-1)
    mean_response = mean_response + vektorlang(round(ons_first(ii)*1000):round((ons_first(ii)+cur_l)*1000));
end
mean_response = mean_response/ii;
figure();plot(mean_response);


