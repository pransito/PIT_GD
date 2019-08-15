% MAKE RANDPERM

% makes a randperm by TOTE; makes a randperm of gamble options then tests how even the
% randperm is if split into 5 parts according to several paramters (ev,
% var, ed, gain, loss); if not even, then new randperm

% parameters; statistical thresholds
P.gmat.alpha_1 = 0.2;
P.gmat.alpha_2 = 0.2 ;

% for ED
P.gmat.Q1 = [min(str2num((str2mat(P.gain.strings)))); max(str2num((str2mat(P.loss.strings)))); 0];
P.gmat.Q2 = [max(str2num((str2mat(P.gain.strings)))); min(str2num((str2mat(P.loss.strings)))); 0];

% now add to the gmat.combs a random sample of gmat.combs again to match length of combs to the
% number of stimuli

% first check how short we are in gambles
tmp.gap   = length(P.stimuli.succession)-length(P.gmat.combs);

% testings if additional sampling is ok
% P.os == 0: then test new sample against all other gambles
% p.os == 1: then test new sample against the "oversample"
if tmp.gap > 0
    % if P.os == 1 we will use a certain kind of gmat.combs; those which have been
    % related to big uncertainty in the AD, PG, HC groups in the first study
    % will be oversampled
    if P.os == 1
        load('poa_maps.mat');
        tmp.up  = 0.6;
        tmp.lo  = 0.4;
        tmp.osm = fliplr(M_12 > tmp.lo & M_12 < tmp.up) + (N_12 > tmp.lo & N_12 < tmp.up) + (AD_12 > tmp.lo & AD_12 < tmp.up)';
        tmp.osm_combs = [];
        tmp.count     = 0 ;
        for jj = 1:size(tmp.osm,1)
            for kk = 1: size(tmp.osm,2)
                tmp.count = tmp.count + 1;
                if tmp.osm(jj,kk) > 0
                    tmp.osm_combs=[tmp.osm_combs,P.gmat.combs(:,tmp.count)];
                end
            end
        end
    end
    
    % testing what against what?
    if P.os == 0
        % here we test the complete gamble matrix against the random smaller sample
        % from the complete gamble matrix 
        tmp.gap_vector = [repmat(1,1,length(P.gmat.combs)), repmat(2,1,tmp.gap)]';
    elseif P.os == 1
        % here we would like to test the complete os gamble matrix against
        % a small sample of the os gamble matrix
        tmp.gap_vector = [repmat(1,1,length(tmp.osm_combs)), repmat(2,1,tmp.gap)]';
    end
    
    while 1
        tmp.shuffled = [];
        % first we need to see that the gamble matrix/os gamble matrix is
        % long enough (longer than gap); at the same time we shuffle the
        % thing;
        while 1
            if P.os == 0
                tmp.shuffled = [tmp.shuffled,P.gmat.combs(:,randperm(length(P.gmat.combs)))];
            elseif P.os == 1
                tmp.shuffled = [tmp.shuffled, tmp.osm_combs(:,randperm(length(tmp.osm_combs)))];     
            end
            if length(tmp.shuffled) >= tmp.gap
                break
            end
        end
        
        if P.os == 0
            tmp.added    = [P.gmat.combs, tmp.shuffled(:,1:tmp.gap)];
        elseif P.os == 1
            tmp.added    = [tmp.osm_combs, tmp.shuffled(:,1:tmp.gap)];
        end
        
        % testing if additional sample is representative of first complete
        % part;
        % convert to actual numeric values of gain and loss
        tmp.gain = tmp.added(1,:);
        tmp.loss = tmp.added(2,:);
        tmp.gain = str2num(cell2mat(P.gain.strings(tmp.gain)));
        tmp.loss = P.loss.strings(tmp.loss);
        new.loss = [];
        for gg = 1:length(tmp.loss);
            new_loss(gg) = str2num(tmp.loss{gg});
        end
        tmp.loss = new_loss;
        tmp.gain = tmp.gain';
        % EV
        for ii = 1:length(tmp.added)
            tmp.gmat.ev(ii) = tmp.gain(ii)*0.5 + tmp.loss(ii)*0.5;
        end
        if test_randperm(tmp.gmat.ev, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        
        % VAR
        for ii = 1:length(tmp.added)
            tmp.gmat.var(ii) = (tmp.gain(ii)*0.5 - tmp.loss(ii)*0.5)^2;
        end
        if test_randperm(tmp.gmat.var, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        
        % RATIO
        for ii = 1:length(tmp.added)
            tmp.gmat.rat(ii) = tmp.gain(ii)/tmp.loss(ii);
        end
        if test_randperm(tmp.gmat.rat, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        
        % ED & abs(ed)
        for ii = 1:length(tmp.added)
            tmp.gmat.ed(ii) = calc_ed(tmp.gain(ii),tmp.loss(ii), P.gmat.Q1, P.gmat.Q2);
        end
        tmp.gmat.ed_abs = abs(tmp.gmat.ed);
        if test_randperm(tmp.gmat.ed, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        if test_randperm(tmp.gmat.ed_abs, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        
        % GAIN & LOSS
        if test_randperm(tmp.gain, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        if test_randperm(tmp.loss, tmp.gap_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
            continue
        end
        % if reached until here, then all tests passed; get out
        break
    end
end

%% NOW TEST WHETHER PER CONDITION THE GAMBLE SELECTION IS BALANCED

% P.gmat.combs gets updated (complete matrix plus the additional gambles
% (os or normal sample from complete matrix))
% shuffle the combs vector at same time
if P.os == 0
    P.gmat.combs = tmp.added(:,randperm(length(tmp.added)));
elseif P.os == 1
    P.gmat.combs = [P.gmat.combs,tmp.shuffled(:,1:tmp.gap)];
    P.gmat.combs = P.gmat.combs(:,randperm(length(P.gmat.combs)));
end

% make a cond vector ([1 1 1 1 1 2 2 2 2 3 3 3 3 3 3 4 4 4 4])
P.gmat.cond_vector = [];
for ii=1:P.gmat.n_cond
    P.gmat.cond_vector = [P.gmat.cond_vector;repmat(ii,P.gmat.cond.n(ii),1)];
end

% make a randperm
% calculate the interesting paramters and test whether good randperm
% supervisor == 0 means NOT OKAY

% count the iterations
count = 0;
while 1
    count = count +1;
    % make the randperm for this subject
    P.gmat.randp = randperm(length(P.gmat.cond_vector));
    
    % convert to gain and loss values
    tmp_gain = P.gmat.combs(1,P.gmat.randp);
    tmp_loss = P.gmat.combs(2,P.gmat.randp);
    tmp_gain = str2num(cell2mat(P.gain.strings(tmp_gain)));
    tmp_loss = P.loss.strings(tmp_loss);
    new_loss = [];
    for gg = 1:length(tmp_loss);
        new_loss(gg) = str2num(tmp_loss{gg});
    end
    tmp_loss = new_loss;
    tmp_gain = tmp_gain';
    
    % EV
    for ii = 1:length(P.gmat.randp)
        P.gmat.ev(ii) = tmp_gain(ii)*0.5 + tmp_loss(ii)*0.5;
    end
    if test_randperm(P.gmat.ev, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    
    % VAR
    for ii = 1:length(P.gmat.randp)
        P.gmat.var(ii) = tmp_gain(ii)*0.5 - tmp_loss(ii)*0.5^2;
    end
    

    if test_randperm(P.gmat.var, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    
    % RATIO
    for ii = 1:length(P.gmat.randp)
        P.gmat.rat(ii) = tmp_gain(ii)/tmp_loss(ii);
    end
    if test_randperm(P.gmat.rat, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    
    % ED & abs(ed)
    for ii = 1:length(P.gmat.randp)
        P.gmat.ed(ii) = calc_ed(tmp_gain(ii),tmp_loss(ii), P.gmat.Q1, P.gmat.Q2);
    end
    P.gmat.ed_abs = abs(P.gmat.ed);
    if test_randperm(P.gmat.ed, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    if test_randperm(P.gmat.ed_abs, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    
    % GAIN & LOSS
    if test_randperm(tmp_gain, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    if test_randperm(tmp_loss, P.gmat.cond_vector, P.gmat.alpha_1, P.gmat.alpha_2) == 0
        continue
    end
    
    % awkward succession test (gambles must not be the same in a row)
    if agk_awkward_succession_test(P) == 0
        continue
    end
    
    % if reached until here, then all tests passed; get out
    break
end

