%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%% PDT TASK 0.3 %%%%%%%%%%%%%%%%%%%
%%%% ALEXANDER GENAUCK %%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Bitte MARKER einfügen bei 'MARKER'
% P.Screen.factor einstellen, um Screen-Window-Größe nach
% Belieben einzustellen555555

%% SETTINGS
% clear workspace
clear all
% set rand function to a unique state based on clock (only for 2015
% version)
if ~strcmp(version ('-release'),'2009a')
    rng('shuffle')
else
    rand('state',sum(100*clock));
end
% record time and date
P.clock.begin = fix(clock);

% with physio recording?
P.physio = 0;

% debug mode?
P.debug  = 0;
% left handed?
% from September 2016 on use lefthanded always, because right hand box
% broken
% lefthanded and righthanded people use the lefthanded box;
% 28.07.2017: box seems fixed: so now can use right box
% again
P.lefthanded = 0;

% randomize direction of options
P.rand_direc_options = 1;

if P.debug == 1
    disp('YOU ARE RUNNING PDT DEBUG MODE!!!')
end

% with
% scanner?
P.scanner = 1;

% at MRI possible to manually set the used screensize
P.Screen.manual_set = 1;

if P.scanner == 1
    P.screenpointer = 2;
else
    P.screenpointer = 0;
end

% What is the code the scanner sends when ready to start experiment?
MRITriggerCode = 53;
NumInitialfMRITriggers = 1; %?

% only randperm generation?
P.onlyrp = 0;

% check if physio in MRI is running
if menu('IS PHYSIO TURNED ON?','YES') == 0
    error('I abort because physio is not turned on.')
end

%Error catcher inserted by Thor P. Nielsen 30/08/2016
if P.onlyrp==1
   disp('WARNING:  YOU ARE ABOUT TO START SIMULATING 1000s OF DATA!!!');
   disp('To switch to regular setting, set P.onlyrp to 1 in PDT_mod_MRT_PG_withpauseinmiddle_NEW.m ');
end

P.onlyrpsubs = 201:990;

% skip instr?
P.skip_instr = 1;
if P.skip_instr == 1
    disp('YOU ARE SKIPPING INSTRUCTIONS!!!')
end

% pic rec task; what is the possible gain?
P.picrec.pos_gain = .4;

% after how many trials should there be a break? no scan stop!
P.breaks.n   = 50;

% gamble paramters; min_gam: minimum num of gambles which need to be
% accepted; sam: size of sample of all gambles which will be played; wager:
% how money in the beginning to play with?
P.min_gam = 5 ;
P.sam     = 5 ;
P.wager   = 20;
if P.physio == 1
    IOPort('CloseAll');
    % Ruhe!
    IOPort('Verbosity',0);
    markcom= IOPort('OpenSerialPort', 'COM3');
    IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % schalte DTR aus (ja, =1 bedeutet AUS!)
    
    % START PHYSIOLOGICAL RECORDING
    AI = analoginput('mcc'); % öffne den Analog-Digital-Wandler ('mcc')
    addchannel(AI, 0:3); % füge 4 kanäle hinzu (Marker,EDA,EMG1,EMG2)
    AISR=1000;
    set(AI, 'SampleRate', AISR); % setze die SampleRate fest
    set(AI, 'SamplesPerTrigger', 10000000); % setze die samples per Trigger fest
    stop(AI); % falls das Ding noch läuft;
    
    SAcq = get(AI,'SamplesAcquired');  % schaut, wieviele samples man aufgezeichnet hat
    if SAcq > 0
        a = getdata(AI,SAcq); % löschend der vorhandenen Daten???
    end
    WaitSecs(2);
    start(AI); % der AD Wandler beginnt zu samplen
end

% Here we call some default settings for setting up Psychtoolbox
% PsychDefaultSetup(2);

% path
cur.path.pwd       = pwd;
cur.path.pic       = 'VPPG_stim_04_reresized\PG';
cur.path.pic_instr = 'VPPG_stim_04_reresized\instruc_pic';
cur.path.lib       = 'library';
cur.path.dat       = 'Daten';
cur.path.ins       = 'instr';
cur.path.pic_dis   = 'distr_pics';
cur.path.gmat      = 'gmat_MRI';
% the original path of this MATLAB
cur.path.org = path;
% we add the library of PDT experiment to the search path
path(cur.path.org,[cur.path.pwd '\' cur.path.lib])

% read in stimuli
% number of stim per cat (only pos and neg)
tmp.n_stim = 45;
% all in one bucket, die Kategorien gehen aus den Namen hervor
% first old study (pos, neg), then new study (-1 0 1)
cd(cur.path.pwd)
cd(cur.path.pic)
stimuli.names = ls('*.jpg');
for ii = 1:length(stimuli.names)
    stimuli.pics{ii} = imread([pwd '\' stimuli.names(ii,1:end)]);
end
P.stimuli.total = ii;
tmp.ind = 1:ii;
tmp.sizescon{1} = length(ls('1*.jpg')); % gam
tmp.sizescon{2} = length(ls('2*.jpg')); % neg
tmp.sizescon{3} = length(ls('3*.jpg')); % pos
tmp.sizescon{4} = length(ls('6*.jpg')); % neuaw

% inflate the neutral, pos, neg pics
tmp.newind = tmp.ind(1:tmp.sizescon{1});
tmp.newind = [tmp.newind, tmp.ind((tmp.sizescon{1}+1):(tmp.sizescon{1}+tmp.sizescon{2}))];
tmp.curend = tmp.sizescon{1};

cur_addon_number    = tmp.n_stim-tmp.sizescon{2};
cur_addon_selection = tmp.ind((tmp.curend+1):tmp.curend+tmp.sizescon{2});
cur_addon_selection = cur_addon_selection(randperm(length(cur_addon_selection)));
cur_addon_selection = cur_addon_selection(1:cur_addon_number);
tmp.newind = [tmp.newind, tmp.ind(cur_addon_selection)];
tmp.curend = tmp.curend+tmp.sizescon{2};

tmp.newind = [tmp.newind, tmp.ind((tmp.curend+1):(tmp.curend+tmp.sizescon{3}))];
cur_addon_number    = tmp.n_stim-tmp.sizescon{3};
cur_addon_selection = tmp.ind((tmp.curend+1):tmp.curend+tmp.sizescon{3});
cur_addon_selection = cur_addon_selection(randperm(length(cur_addon_selection)));
cur_addon_selection = cur_addon_selection(1:cur_addon_number);
tmp.newind = [tmp.newind, tmp.ind(cur_addon_selection)];
tmp.curend = tmp.curend+tmp.sizescon{3};

tmp.newind = [tmp.newind, tmp.ind((tmp.curend+1):(tmp.curend+tmp.sizescon{4}))];
cur_addon_number    = tmp.n_stim-tmp.sizescon{4};
cur_addon_selection = tmp.ind((tmp.curend+1):tmp.curend+tmp.sizescon{4});
cur_addon_selection = cur_addon_selection(randperm(length(cur_addon_selection)));
cur_addon_selection = cur_addon_selection(1:cur_addon_number);
tmp.newind = [tmp.newind, tmp.ind(cur_addon_selection)];
tmp.curend = tmp.curend+tmp.sizescon{4};

tmp.newind = tmp.newind(randperm(length(tmp.newind)));
P.stimuli.succession = tmp.newind;

% which numbers will be used in the LA task (as in old LA task)
P.gain.strings = {'+14';'+16';'+18';'+20';'+22';'+24'; '+26'; '+28'; '+30'; '+32';'+34';'+36'};
P.loss.strings = {'-7';'-8';'-9';'-10';'-11';'-12';'-13';'-14';'-15';'-16';'-17';'-18'};

% make gamble matrix
P.gain.indices = linspace(1,12,12);
P.loss.indices = linspace(1,12,12);
P.gmat.combs   = CombVec(P.gain.indices,P.loss.indices);
% if there are more stimuli than gambles, should additional gambles then be
% sampled from only those gambles which have been associated with high
% uncertainty? set 0 or 1; in case of 0 all additional gambles will be
% sampled with equal probability from original gambles
P.os           = 0;

% make randperm for this subject (similar variance, EV, ed, ratio, variance
% and mean of gain and loss)
P.gmat.n_cond = 4;
% how many stimuli in each condition?
% first con is gam (67 pics); stick with n
% second two have n_stim (45)
for ii = 1:P.gmat.n_cond
    if ii == 1
        P.gmat.cond.n(ii) = 67;
    else
        P.gmat.cond.n(ii) = tmp.n_stim;
    end
end

% make batch randperms
if P.onlyrp
    batch_make_randperms
end

% settings for PDT task display
% the initial text size; will be calibrated automatically
P.textsize = 22;
% text size for instructions as fraction respective to P.textsize
P.textsize_ins_f = 0.55;
% text size for options as fraction respective to P.textsize
P.textsize_opt_f = 0.75;
P.textsize_cross = round(P.textsize*1.125);
% textstyle: 1 is bold
P.textstyle = 1;
P.textfont = 'Arial';

% the selection options
P.opt.str{1,1}  = 'ja';
P.opt.str{1,2}  = 'eher ja';
P.opt.str{1,3}  = 'eher nein';
P.opt.str{1,4}  = 'nein';
P.opt.num{1}    = [1 2 3 4];

P.opt.str{2,1}  = 'nein';
P.opt.str{2,2}  = 'eher nein';
P.opt.str{2,3}  = 'eher ja';
P.opt.str{2,4}  = 'ja';
P.opt.num{2}      = [4 3 2 1];

% keyboard codes for keys used by subject to indicate choices
if P.scanner == 1
    if P.lefthanded
        P.opt.kbc   = [57 56 55 54];
    else
        P.opt.kbc   = [49 50 51 52];
    end
else
    % X C V B in Adlershof (left handed people)
    % P.opt.kbc   = [88 67 86 66];
    
    % N M , . in Adlershof (right handed people)
    P.opt.kbc   = [78 77 188 190];
end
% the deadline until when a decision must be made (in s)
if P.debug
    P.opt.dl   = 0.01;
else
    P.opt.dl   = 2.5;
end

% how much bigger (in pixels) should the yellow rect around options be?
P.opt.enlarge  = 6;
% how large the frame to indicate chosen option?
P.opt.frame_pt = 2;

% selection options for pic recognition task in the end
P.opt.picrec.str{1}  = 'bekannt';
P.opt.picrec.str{2}  = 'unbekannt';
P.opt.picrec.num     = [1 2];
P.opt.picrec.kbc     = [49 50];
if P.lefthanded
    P.opt.picrec.kbc     = [57 56];
end
P.opt.picrec.dl      = 5;


% instructions
P.instr.color = [200 200 200];
P.instr.vspace= 2;
% safety period to wait
P.instr1_tsafe = 0.5;
P.instr.slow.string = 'Zu langsam!';
P.instr.slow.time   = 0.5          ;
if P.debug
    P.instr.slow.time   = 0.02     ;
end
P.instr.weiter = 'Weiter mit beliebiger Taste';

% selection option rectangle offset for display
P.opt.picrec.offset = 20;

% where to put options: x
P.opt.offset{1} = 60;
P.opt.offset{2} = 20;

% prepare the rectangles for the LA task
P.rectLA.color    = [255 255 255 230];
% color for neutral gray stimulus
P.picgray.color   = [50 50 50 255];

% Experiment settings
% durations (for stimulus duration and for iti and for gamble watch)
stimuli.duration.min = 3.8;
stimuli.duration.max = 5.5;

if P.debug
    stimuli.duration.min = 0.05;
    stimuli.duration.max = 0.06;
end

P.gamble_watch.durmin = 4.0;
P.gamble_watch.durmax = 4.9;

if P.debug
    P.gamble_watch.durmin = 0.03;
    P.gamble_watch.durmax = 0.08;
end

if P.scanner == 1 && P.debug == 0
    %     P.iti.min = 3;
    %     P.iti.max = 16;
    P.iti.min = 4;
    P.iti.max = 8;
else
    if P.debug
        P.iti.min = 0.02;
        P.iti.max = 0.03;
    else
        P.iti.min = 2.5;
        P.iti.max = 5.5;
    end
end

% set textbox offset in y direction
% Drawformattedtext returns a text box which is too large in y direction;
% for rectLA
% so correction for this by hand: used to be 0.28
P.textbox_offset        = 0.28; % y direction as a fraction added
P.textbox_offset_x      = 20;   % x direction in pixels
% when did I start the script running?
P.t.start_script = GetSecs;

% MARKER 'START SCRIPT' 20ms
if P.physio == 1
    IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
    WaitSecs(0.02);
    IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
end

%% SUBJECT INFO

if ~P.onlyrp
    
    % get some info on VP
    prompt={'VPnummer','VerstärkungsfaktorEDA'};
    name='VL: Bitte eingeben!';
    numlines=1;
    defaultanswer={'9999','1000'};
    answer=inputdlg(prompt,name,numlines,defaultanswer);
    
    P.vp.num=answer{1};
    P.vp.vfaktoreda=answer{2};
    
    % get some info on VP
    prompt={'PDT sub study'};
    name='Please indicate PDT sub study.';
    numlines=1;
    defaultanswer={'MRI'};
    tmp.path_study=inputdlg(prompt,name,numlines,defaultanswer);
    
    cur.path.vp = [cur.path.pwd filesep cur.path.dat filesep tmp.path_study{1} filesep P.vp.num];
    P.path.vp   = cur.path.vp;
    agk_mkdir_ex(cur.path.pwd, [cur.path.dat filesep tmp.path_study{1} filesep P.vp.num]);
    
    % get a ready-made randperm (a gmat)
    % CAVE: the pics here and on the gmat generating machine must be same!
    % in the case of out-of-range vpnum we will take a random prepared gmat
    tmp.pwd = pwd;
    cd([cur.path.pwd filesep cur.path.gmat])
    tmp.lsgmats = ls('gmat_*');
    tmp.found_gmat = 0;
    for ff = 1:length(tmp.lsgmats)
        tmp.str = tmp.lsgmats(ff,:);
        tmp.str = textscan(tmp.str,'%s','delimiter','_');
        tmp.str = textscan(tmp.str{1}{2},'%s','delimiter','.');
        tmp.str = tmp.str{1}{1};
        if strcmp(tmp.str,P.vp.num)
            load(tmp.lsgmats(ff,:))
            P.gmat = cur_gmat;
            tmp.found_gmat = 1;
            break
        end
    end
    % check if a gmat has been found
    if tmp.found_gmat == 0
        disp(['NO GMAT FOUND FOR THIS SUBJECT. WILL USE A RANDOM' ...
            ' PREPARED ONE.']);
        ff = randi(length(tmp.lsgmats));
        load(tmp.lsgmats(ff,:))
        P.gmat = cur_gmat;
        tmp.found_gmat = 1;
    end
    % final check that gmat has been found
    if tmp.found_gmat == 1
        disp('FOUND A GMAT. I CONTINUE.')
    else
        error('DID NOT FIND A GMAT. I ABORT. CHECK ON THIS!')
    end
    % return to working directorx
    cd(tmp.pwd)
    
    % calculate breaks
    P.breaks.vec = agk_make_breaks(P.gmat.combs,P.breaks.n);
    P.breaks.vec = P.breaks.vec([1,3]);
    
    % save the P.gmat.randp per cond
    for hh=1:P.gmat.n_cond
        P.gmat.randp_per_cond{hh} = P.gmat.randp(P.gmat.cond_vector == hh);
    end
    
    % initialize names and counts for the conditions
    P.gmat.cond.names = {'gam','neg','pos','neuaw'};
    P.gmat.cond.count = [0 0 0 0];
    
    % make left/right randomization for 4 conditions
    % 0 1 vector indicates 1 = "gain right"
    tmp.lr = repmat([0 1],1, ceil(length(P.gmat.randp)/2));
    if length(tmp.lr) > length(P.gmat.randp)
        tmp.lr = tmp.lr(1:end-1);
    end
    for kk = 1:P.gmat.n_cond
        P.gmat.randp_gr{kk} = tmp.lr(P.gmat.cond_vector==kk);
        P.gmat.randp_gr{kk} = P.gmat.randp_gr{kk}(randperm(length(P.gmat.randp_gr{kk})));
    end
    
    % make left/right randomization for option for 4 conditions
    % 0 1 vector indicates 1 = "gain right"
    tmp.lro = repmat([0 1],1, ceil(length(P.gmat.randp)/2));
    if length(tmp.lr) > length(P.gmat.randp)
        tmp.lro = tmp.lro(1:end-1);
    end
    for kk = 1:P.gmat.n_cond
        P.gmat.randp_gro{kk} = tmp.lro(P.gmat.cond_vector==kk);
        P.gmat.randp_gro{kk} = P.gmat.randp_gro{kk}(randperm(length(P.gmat.randp_gro{kk})));
    end
    
    % read in all the instruction slides
    tmp.pwd = pwd;
    cd(cur.path.pwd)
    cd(cur.path.ins)
    tmp.ins.ls = ls('ins*.txt');
    for kk = 1:size(tmp.ins.ls,1)
        tmp.fileID = fopen(tmp.ins.ls(kk,:),'r');
        P.instr.begin.slides{kk} = textscan(tmp.fileID,'%s');
        tmp.ins.str = [];
        for ll = 1:length(P.instr.begin.slides{kk}{1})
            tmp.ins.str = [tmp.ins.str ' ' P.instr.begin.slides{kk}{1}{ll}];
        end
        P.instr.begin.slides{kk} = [tmp.ins.str '\n\n' P.instr.weiter];
        fclose(tmp.fileID);
    end
    
    % inputdlg lässt den User etwas eingeben
    % 1 bedeutet, 1 Zeile zu Verfügung
    % '999' ist Default
    demograph=inputdlg({'Wie alt sind Sie?','Geschlecht?', ...
        'Bildungsgrad?'},'Demographie',1,{'99','eingeben','Studium'});
    
    % cell array
    % Alter
    P.vp.age=str2double(demograph{1});
    
    % Geschlecht, education
    P.vp.sex=demograph{2};
    P.vp.bildung=demograph{3};
    
    % heightnum=str2num(heightarr{1});
    % Output-Datei anlegen
    outputname=[cur.path.vp filesep P.vp.num '_output.txt'];
    fileID=fopen(outputname,'at');
    
    % erste Zeile Schreiben
    fprintf(fileID, 'gain\t');
    fprintf(fileID, 'loss\t');
    fprintf(fileID, 'choice\t');
    fprintf(fileID, 'rt\t');
    fprintf(fileID, 'cat\t');
    fprintf(fileID, 'side\t');
    fprintf(fileID, 'st_dur \n');
    
    % Demographie-Datei anlegen
    demographname=[cur.path.vp filesep P.vp.num '_demograph.txt'];
    fileID_demo=fopen(demographname,'at');
    
    % erste Zeile Schreiben
    fprintf(fileID_demo, 'vpn\t');
    fprintf(fileID_demo, 'age\t');
    fprintf(fileID_demo, 'sex\t');
    fprintf(fileID_demo, 'edu\n');
    
    % Folgendes nur nötig, wenn man im PCPool arbeitet/teilweise aber auch zu
    % Hause oder an sonstigen Rechnern
    Screen('Preference', 'SkipSyncTests', 1);
    Screen('Preference', 'Verbosity', 1);
    
    % Onscreen-Fenster öffnen und formatieren
    % 'rect' keine Angabe, default Vollbild
    % save the original values;
    if P.Screen.manual_set == 0
        screenSize=get(0,'screensize');
    elseif P.Screen.manual_set == 1
        screenSize= [1 1 1024 768];
    end
    
    P.Screen.breite=screenSize(3);
    P.Screen.hoehe=screenSize(4);
    % for debug only open small window
    if P.debug && P.scanner == 0
        P.Screen.factor = 0.5;
    else
        P.Screen.factor = 1;
    end
    % color in bg
    P.screen.color  = [0 0 0 255];
    % size of window
    P.Screen.rect = [0 0 P.Screen.breite*P.Screen.factor P.Screen.hoehe*P.Screen.factor];
    
    % before we start; calibrating procedure for texts and boxes
    calibrate_text_boxes
    
    if P.Screen.manual_set
        P.textsize = 53;
    end
    
    % prep the ITI "x"
    off.cross.color   = [0 0 0 0];
    if P.scanner ==1
        off.cross.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.cross.color);
    else
        off.cross.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.cross.color,P.Screen.rect);
    end
    % (Formatierung gilt für gesamten Onscreen; Onscreen-Fenster muss dazu geöffnet sein)
    Screen('TextFont',off.cross.screen,P.textfont);
    Screen('TextSize',off.cross.screen,P.textsize_cross);
    Screen('TextStyle',off.cross.screen,P.textstyle);
    % draw the '+'
    DrawFormattedText(off.cross.screen,'x','center','center',P.instr.color, [], [], [], 3);
    
    % open an off-screen window for painting the dark gray neutral pic stimulus
    off.gray.color   = [0 0 0 0];
    if P.scanner  == 1
        off.gray.screen  = Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color);
    else
        off.gray.screen  = Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color,P.Screen.rect);
    end
    stimuli.position = [rect1(3)/2-0.5*stimuli.size(1),rect1(4)/2-0.5*stimuli.size(2),rect1(3)/2+0.5*stimuli.size(1),rect1(4)/2+0.5*stimuli.size(2)];
    Screen('FillRect', off.gray.screen, P.picgray.color, stimuli.position);
    
    % open an off-screen window for painting the numbers in the rectLAs
    off.numbers.color =[0 0 0 0];
    if P.scanner == 1
        off.numbers.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.numbers.color);
    else
        off.numbers.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.numbers.color,P.Screen.rect);
    end
    Screen('TextFont',off.numbers.screen,P.textfont);
    Screen('TextSize',off.numbers.screen,P.textsize);
    Screen('TextStyle',off.numbers.screen,P.textstyle);
    
    % open an off-screen window for painting the two boxes with options
    % see-through background
    off.rectLA.color = [0 0 0 0];
    if P.scanner == 1
        off.rectLA.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.rectLA.color);
    else
        off.rectLA.screen=Screen('OpenOffscreenWindow',P.screenpointer,off.rectLA.color,P.Screen.rect);
    end
    Screen('FillRect', off.rectLA.screen,P.rectLA.color,P.rectLA.centeredL);
    Screen('FillRect', off.rectLA.screen,P.rectLA.color,P.rectLA.centeredR);
    
    P.textbox_offset_yellow = P.textbox_offset*3.8;
    
    % space between options
    P.opt.space   = stimuli.size(1)/6;
    % where to put options: y
    P.opt.begin.y = P.yCenter + (0.75)*stimuli.size(2);
    
    % off-screen window to measure the complete length of options
    if P.scanner == 1
        [fenster1_off,rect1_off]=Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color);
    else
        [fenster1_off,rect1_off]=Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color,P.Screen.rect);
    end
    Screen('BlendFunction', fenster1_off, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    Screen('TextFont',fenster1_off,P.textfont);
    Screen('TextSize',fenster1_off,round(P.textsize*P.textsize_opt_f));
    Screen('TextStyle',fenster1_off,P.textstyle);
    
    % (Formatierung gilt für gesamten Onscreen; Onscreen-Fenster muss dazu geöffnet sein)
    Screen('TextFont',fenster1,P.textfont);
    Screen('TextSize',fenster1,P.textsize);
    Screen('TextStyle',fenster1,P.textstyle);
    
    % include code for options measuring
    measure_options
    
    % Close and reopen offscreen window
    Screen('Close', fenster1_off)
    if P.scanner == 1
        [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color);
    else
        [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color,P.Screen.rect);
    end
    % (Formatierung gilt für gesamten Onscreen; Onscreen-Fenster muss dazu geöffnet sein)
    Screen('TextFont',fenster1,P.textfont);
    Screen('TextSize',fenster1,P.textsize);
    Screen('TextStyle',fenster1,P.textstyle);
    
    % make jittered vector of itis
    P.iti.vec = jitter(P.iti.min, P.iti.max, numel(P.stimuli.succession));
    P.iti.vec = P.iti.vec(randperm(length(P.iti.vec)));
    
    P.gamble_watch.durations = jitter(P.gamble_watch.durmin,P.gamble_watch.durmax,numel(P.stimuli.succession));
    P.gamble_watch.durations = P.gamble_watch.durations(randperm(length(P.gamble_watch.durations)));
    
    % make jittered vector of stimuli durations
    stimuli.duration.vec = jitter(stimuli.duration.min, stimuli.duration.max, numel(P.stimuli.succession));
    stimuli.duration.vec = stimuli.duration.vec(randperm(length(stimuli.duration.vec)));
    
    % Cursor verstecken
    if P.debug == 0
        HideCursor
    end
    
    
    %% Show instructions
    % allow fourth color number indicate transparency
    Screen('BlendFunction', fenster1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    % set the text size
    Screen('TextSize',fenster1,round(P.textsize*P.textsize_ins_f));
    
    if P.skip_instr == 0
        % prepare the instruction pic
        tmp.pwd = pwd;
        cd(cur.path.pwd)
        cd(cur.path.pic_instr)
        stimuli.instr_pic=imread('instruc_pic.jpg');
        stimuli.instr_pic=imageresize(stimuli.instr_pic,0.3,0.3);
        off.instr_pic.color = [0 0 0 0];
        P.tx_instr=Screen('MakeTexture', fenster1, stimuli.instr_pic);
    end
    % prepare the rectLA with numbers as texture; right and left version
    rect_num_tx_r         = make_rect_num_tx(fenster1, rect1,P,0,[3 8]);
    rect_num_tx_l         = make_rect_num_tx(fenster1, rect1,P,1,[3 8]);
    rect_num_opt_tx_l     = make_rect_num_opt_tx(fenster1, rect1,P,off.opt.screen,1,[3 8]);
    rect_num_opt_box_tx_l = make_rect_num_opt_box_tx(fenster1, rect1,P,tmp,off.opt.screen,1,[3 8]);
    
    % measure "wrap at"
    P.instr.wrap = 300;
    % open an off-screen window to do it
    off.wrap.color = P.screen.color;
    while 1
        if P.scanner == 1
            [off.wrap.screen,off.wrap.rect]=Screen(P.screenpointer,'OpenOffscreenWindow',off.wrap.color);
        else
            [off.wrap.screen,off.wrap.rect]=Screen(P.screenpointer,'OpenOffscreenWindow',off.wrap.color,P.Screen.rect);
        end
        Screen('TextSize',off.wrap.screen,round(P.textsize*P.textsize_ins_f));
        [nx,ny, tmp.textbounds_instr] = DrawFormattedText(off.wrap.screen,P.instr.begin.slides{1}, 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], P.instr.vspace);
        Screen('Close',off.wrap.screen)
        if tmp.textbounds_instr(3) >= rect1(3)
            P.instr.wrap = P.instr.wrap-2;
        else
            break
        end
    end
    
    if P.skip_instr ~= 1
        % Instruktion in den Off-Screen schreiben
        % set some coordination
        P.instr.box.shift = 0.7;
        P.instr.box_offset= 1.0667;
        
        off.white_frame.color =[0 0 0 0];
        if P.scanner == 1
            [off.white_frame.screen,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',off.white_frame.color);
        else
            [off.white_frame.screen,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',off.white_frame.color,P.Screen.rect);
        end
        Screen('BlendFunction', off.white_frame.screen, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
        Screen('FrameRect', off.white_frame.screen, P.instr.color, rect1, P.opt.frame_pt*2);
        
        for ll = 1:length(P.instr.begin.slides)
            switch ll
                case {2,15}
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,off.cross.screen,rect1,CenterRect(rect1,[rect1(1)*0.6, rect1(2), rect1(3), rect1(4)*P.instr.box.shift*P.instr.box_offset]));
                case 3
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,P.tx_instr,[],CenterRect(stimuli.position*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                case 5
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,P.tx_instr,[],CenterRect(stimuli.position*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_tx_r,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                case 8
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,P.tx_instr,[],CenterRect(stimuli.position*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_tx_l,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                case 12
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,P.tx_instr,[],CenterRect(stimuli.position*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_tx_l,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_opt_tx_l,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                case 14
                    tmp.screen = 1;
                    Screen('DrawTexture',fenster1,off.white_frame.screen,rect1,CenterRect(rect1*0.4 ,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,P.tx_instr,[],CenterRect(stimuli.position*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_tx_l,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                    Screen('DrawTexture',fenster1,rect_num_opt_box_tx_l,[],CenterRect(rect1*0.9,[rect1(1), rect1(2), rect1(3), rect1(4)*P.instr.box.shift]));
                otherwise
                    tmp.screen = 0;
            end
            if tmp.screen == 1
                DrawFormattedText(fenster1,P.instr.begin.slides{ll}, 'center' , P.yCenter + 0.20*P.yCenter ,P.instr.color, P.instr.wrap, [], [], P.instr.vspace);
            else
                DrawFormattedText(fenster1,P.instr.begin.slides{ll}, 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], P.instr.vspace);
            end
            % in den On-Screen flippen
            Screen('flip', fenster1);
            % safety wait and go on with key stroke
            WaitSecs(P.instr1_tsafe)
            pause
            Screen('TextSize',fenster1,round(P.textsize*P.textsize_ins_f));
        end
        
    end
    
    % close all windows (to save memory)
    sca
    
    % open fresh
    if P.scanner == 1
        [fenster1,rect1]=Screen('OpenWindow',P.screenpointer,P.screen.color);
    else
        [fenster1,rect1]=Screen('OpenWindow',P.screenpointer,P.screen.color, P.Screen.rect);
    end
    
    % allow fourth color number indicate transparency
    Screen('BlendFunction', fenster1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
    
    % for options we need to reset this here
    % where to put options: x
    P.opt.begin.x{1} = P.opt.begin.x{1} - P.opt.offset{1};
    P.opt.begin.x{2} = P.opt.begin.x{2} - P.opt.offset{2};
    
    % where to put options of picrec task: x
    P.opt.picrec.begin.x = P.opt.picrec.begin.x - P.opt.picrec.offset;
    
    % reset the text features
    Screen('TextFont',fenster1,P.textfont);
    Screen('TextSize',fenster1,P.textsize);
    Screen('TextStyle',fenster1,P.textstyle);
    
    % Hide the cursor
    if P.debug == 0
        HideCursor
    end
    
    %% Experiment startet
    
    % a little screen to say we are starting very soon
    if P.scanner == 0
        agk_gleich_gehts_los_screen(fenster1,1,P)
    elseif P.scanner == 1
        agk_gleich_gehts_los_screen(fenster1,[],P) % no duration indicated, so WaitTrigger has to do it
        P.t.triggerscannert0 = WaitForMRITrigger(MRITriggerCode, NumInitialfMRITriggers, []); % last input variable "display" I don't understand
        % HERE USUALLY A FIXATION CROSS
        WaitSecs(10);
    end
    
    %initial time to correct duration of ITI is 0
    tmp.t_corr_iti = 0;
    % get the beginning of experiment (IF SCANNER THEN TRIGGER OF SCANNER
    % IS START)
    if P.scanner == 1
        P.t.start_exp = P.t.triggerscannert0;
    else
        P.t.start_exp = GetSecs;
    end
    
    % trials start here
    % only some stimuli for debug
    % normally length(P.gmat.combs)
    for ii = 1:length(P.gmat.combs)
        %for ii = 1:3
        % which category is current stimulus
        % which LA gamble should be thus shown?
        % is gain option on right-hand side now?
        if P.stimuli.succession(ii) ~=999
            P.cur.cat(ii)   = str2num(stimuli.names(P.stimuli.succession(ii),1));
            P.cur.stim{ii}  = stimuli.names(P.stimuli.succession(ii),:);
        else
            P.cur.cat(ii)   = 5;
            P.cur.stim{ii}  = 'gray';
        end
        
        % Note cur gamble and cur side
        tmp.cur_cat = P.cur.cat(ii);
        if tmp.cur_cat == 1
            tmp.cur_cat = 1;
        elseif tmp.cur_cat == 2
            tmp.cur_cat = 2;
        elseif tmp.cur_cat == 3
            tmp.cur_cat = 3;
        elseif tmp.cur_cat == 6
            tmp.cur_cat = 4;
        end
        
        P.gmat.cond.count(tmp.cur_cat) = P.gmat.cond.count(tmp.cur_cat)+1;
        tmp.cat          = tmp.cur_cat;
        tmp.cat_count    = P.gmat.cond.count(tmp.cur_cat);
        P.cur.gamble{ii} = P.gmat.combs(:,P.gmat.randp_per_cond{tmp.cat}(tmp.cat_count));
        P.cur.side(ii)   = P.gmat.randp_gr{tmp.cat}(tmp.cat_count);
        P.cur.diropt(ii) = P.gmat.randp_gro{tmp.cat}(tmp.cat_count);
        
        % fixation cross/ITI
        DrawFormattedText(fenster1,'x','center','center',P.instr.color, [], [], [], 3);
        Screen('flip', fenster1);
        
        % record time of begin of this trial (starts with ITI)
        P.t.cur_trial.iti_on(ii)  =  GetSecs - P.t.start_exp;
        
        % MARKER 'ITI' 1ms
        if P.physio == 1
            IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
            WaitSecs(0.001);
            IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
        end
        
        % wait for iti time;
        P.cur_iti_dur_corr(ii) = P.iti.vec(ii) - tmp.t_corr_iti;
        while GetSecs - P.t.start_exp <= P.t.cur_trial.iti_on(ii) + P.iti.vec(ii) - tmp.t_corr_iti
            
        end
        
        % Stimulus in offscreen malen;
        if P.stimuli.succession(ii) ~=999
            P.tx=Screen('MakeTexture', fenster1, stimuli.pics{P.stimuli.succession(ii)});
            Screen('DrawTexture',fenster1,P.tx);
        else
            Screen('FillRect', fenster1, P.picgray.color, stimuli.position);
        end
        
        % show stimulus
        Screen('flip', fenster1);
        
        % MARKER 'SHOW STIMULUS' 2ms
        if P.physio == 1
            IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
            WaitSecs(0.002);
            IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
        end
        
        % record time for stimulus onset
        P.t.cur_trial.stim_on(ii) = GetSecs - P.t.start_exp;
        
        % paint in offscreen the cue-plus-LA image; correct jitter of image duration for that!
        tmp.t0_paint = P.t.cur_trial.stim_on(ii);
        
        % draw the textures
        if P.stimuli.succession(ii) ~=999
            Screen('DrawTexture',fenster1,P.tx);
        else
            Screen('FillRect', fenster1, P.picgray.color, stimuli.position);
        end
        Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredL);
        Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredR);
              
        if P.cur.side(ii) == 0
            % compute appropriate coordinate (upper left) where to pin point text box
            % left
            tmp.x_halfL = P.gain.size{P.cur.gamble{ii}(1)}(1)/2;
            tmp.y_halfL = P.gain.size{P.cur.gamble{ii}(1)}(2)*P.textbox_offset;
            
            cur.x_textL = P.rectLA.centeredL(1)+P.rectLA.size(1)/2-tmp.x_halfL+P.textbox_offset_x;
            cur.y_textL = P.rectLA.centeredL(2)+P.rectLA.size(2)/2+tmp.y_halfL;
            
            %right
            tmp.x_halfR = P.loss.size{P.cur.gamble{ii}(2)}(1)/2;
            tmp.y_halfR = P.loss.size{P.cur.gamble{ii}(2)}(2)*P.textbox_offset;
            
            cur.x_textR = P.rectLA.centeredR(1)+P.rectLA.size(1)/2-tmp.x_halfR+P.textbox_offset_x;
            cur.y_textR = P.rectLA.centeredR(2)+P.rectLA.size(2)/2+tmp.y_halfR;
            
            DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
            DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
            
        else
            tmp.x_halfL = P.loss.size{P.cur.gamble{ii}(2)}(1)/2;
            tmp.y_halfL = P.loss.size{P.cur.gamble{ii}(2)}(2)*P.textbox_offset;
            
            cur.x_textL = P.rectLA.centeredL(1)+P.rectLA.size(1)/2-tmp.x_halfL+P.textbox_offset_x;
            cur.y_textL = P.rectLA.centeredL(2)+P.rectLA.size(2)/2+tmp.y_halfL;
            
            %right
            tmp.x_halfR = P.gain.size{P.cur.gamble{ii}(1)}(1)/2;
            tmp.y_halfR = P.gain.size{P.cur.gamble{ii}(1)}(2)*P.textbox_offset;
            
            cur.x_textR = P.rectLA.centeredR(1)+P.rectLA.size(1)/2-tmp.x_halfR+P.textbox_offset_x;
            cur.y_textR = P.rectLA.centeredR(2)+P.rectLA.size(2)/2+tmp.y_halfR;
            
            DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
            DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
        end
        
        % correct jittered stimulus duration for time it took to
        % paint in offscreen
        tmp.t1_paint      = GetSecs - P.t.start_exp;
        tmp.t_corr_stim   = tmp.t1_paint - tmp.t0_paint;
        WaitSecs(stimuli.duration.vec(ii) - tmp.t_corr_stim);
        
        % record corrected jitter
        P.cur.stim_dur_corr(ii) = stimuli.duration.vec(ii) - tmp.t_corr_stim;
        
        % flip pic plus gamble (without options)
        Screen('Flip', fenster1);
        
        % wie spät zum Beginn des gamble watch
        tmp.t0_gamble_watch = GetSecs - P.t.start_exp;
        % record time when stimulus+LA period begins
        P.t.cur_trial.stimLA_watch(ii) = tmp.t0_gamble_watch;
        
        % MARKER 'SHOW GAMBLE NO OPTIONS' 1ms
        if P.physio == 1
            IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
            WaitSecs(0.001);
            IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
        end
        
        % draw the textures plus gamble again
        if P.stimuli.succession(ii) ~=999
            Screen('DrawTexture',fenster1,P.tx);
        else
            Screen('FillRect', fenster1, P.picgray.color, stimuli.position);
        end
        Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredL);
        Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredR);
        
        if P.cur.side(ii) == 0
            DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
            DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
        else
            DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
            DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
        end
        
        % Draw the options into buffer
        if P.rand_direc_options == 0
            tmp = draw_options_under_image(0,P,tmp,fenster1); %always standard direction left to right
        elseif P.rand_direc_options == 1
            tmp = draw_options_under_image(P.cur.diropt(ii),P,tmp,fenster1); %always standard direction left to right
        end
        
        % show gamble (no options) a bit
        WaitSecs(P.gamble_watch.durations(ii));
        
        % flip LA gamble plus options onto stimulus
        Screen('Flip', fenster1);
        % wie spät zum Beginn des gambles
        tmp.t0_gamble = GetSecs - P.t.start_exp;
        % record time when stimulus+LA period begins
        P.t.cur_trial.stimLA_on(ii) = tmp.t0_gamble;
        
        % MARKER 'SHOW GAMBLE' 1ms
        if P.physio == 1
            IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
            WaitSecs(0.001);
            IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
        end
        
        % check which option is chosen during decision time
        % default is: nothing chosen
        tmp.reaction=9999;
        while GetSecs - P.t.start_exp <= tmp.t0_gamble + P.opt.dl
            [tmp.keyIsDown, tmp.secs, tmp.keyCode] = KbCheck;
            if tmp.keyIsDown == 1
                tmp.which_key = find(tmp.keyCode==1,1,'first');
                % here, if ESCAPE pressed then exp aborted
                % could included more elaborate abortion routine (saving
                % stuff...)
                if tmp.which_key == 27
                    sca
                    return
                end
                if sum(tmp.which_key == P.opt.kbc)
                    
                    % MARKER 'REACTION' 1ms
                    if P.physio == 1
                        IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
                        WaitSecs(0.001);
                        IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
                    end
                    
                    % record rt and choice and compute iti_corr_time
                    tmp.reaction     = 1;
                    P.cur.rt(ii)     = GetSecs - P.t.start_exp-tmp.t0_gamble;
                    tmp.t_corr_iti   = (tmp.t0_gamble + P.cur.rt(ii)) - (tmp.t0_gamble + P.opt.dl);
                    P.cur.choice(ii) = P.opt.num{P.cur.diropt(ii)+1}(P.opt.kbc == tmp.which_key);
                    
                    % Draw the picture and the rectLA again into off screen
                    % Draw options and numbers also
                    if P.stimuli.succession(ii) ~=999
                        Screen('DrawTexture',fenster1,P.tx);
                    else
                        Screen('FillRect', fenster1, P.picgray.color, stimuli.position);
                    end
                    Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredL);
                    Screen('FillRect', fenster1,P.rectLA.color,P.rectLA.centeredR);
                    
                    if P.rand_direc_options == 0
                        tmp = draw_options_under_image(0,P,tmp,fenster1); %always standard direction left to right
                    elseif P.rand_direc_options == 1
                        tmp = draw_options_under_image(P.cur.diropt(ii),P,tmp,fenster1); %always standard direction left to right
                    end
                    
                    if P.cur.side(ii) == 0
                        DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
                        DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
                    else
                        DrawFormattedText(fenster1,P.loss.strings{P.cur.gamble{ii}(2)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
                        DrawFormattedText(fenster1,P.gain.strings{P.cur.gamble{ii}(1)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
                    end
                    
                    % paint a yellow box around the chosen option into the
                    % off-window fenster1_off
                    if P.cur.diropt(ii) == 0
                        Screen('FrameRect', fenster1, [255 255 0], tmp.textbounds{P.cur.choice(ii)}, P.opt.frame_pt);
                    elseif P.cur.diropt(ii) == 1
                        Screen('FrameRect', fenster1, [255 255 0], tmp.textbounds{agk_recode(P.cur.choice(ii),[1,2,3,4],[4,3,2,1])}, P.opt.frame_pt);
                    end
                    
                    % LA gamble with chosen option marked
                    Screen('flip', fenster1);
                    % record the time
                    P.t.cur_trial.stimLA_off(ii) = GetSecs - P.t.start_exp;
                    
                    % show the marked option for a while
                    WaitSecs(P.instr.slow.time)
                    break
                end
            end
        end
        
        if tmp.reaction==9999
            % MARKER - keine Reaktion (Dummy Marker, damit die gleiche Anzahl
            % an Markern im Physio File enthalten ist
            if P.physio == 1
                IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
                WaitSecs(0.001);
                IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
            end
            
            P.cur.choice(ii) = 5;
            P.cur.rt(ii)     = 99999;
            DrawFormattedText(fenster1,P.instr.slow.string, 'center' , 'center' ,P.instr.color, [], [], [], 2);
            Screen('flip', fenster1);
            
            % record time
            P.t.cur_trial.stimLA_off(ii) = GetSecs - P.t.start_exp;
            WaitSecs(P.instr.slow.time)
        end
        
        % break every P.breaks.n trials
        if sum(ii == P.breaks.vec)
            if P.debug == 0 || P.debug == 1
                 DrawFormattedText(fenster1,['\nKurze Pause.\n' [num2str(ii) ' von ' num2str(length(P.gmat.combs)) '\nDurchgängen geschafft.'] '\nGleich geht es weiter.'],'center','center',P.instr.color, P.instr.wrap, [], [], 3);
                 Screen('flip', fenster1);
                % Wait definitely 6 second
                     WaitSecs(6);
            end
         end

        
        % save P (better on every trial!)
        cur.wd = pwd;
        cd(cur.path.vp)
        save(['P_' P.vp.num],'P')
        cd(cur.wd);
        % end of trials loop
        
        % PAUSE in the middle (STOP EPI by hand)1234
        % cont with '+'
        if ii == round(length(P.gmat.combs)/2)
            DrawFormattedText(fenster1,'Die Hälfte geschafft! \n Wir sprechen kurz mit Ihnen.\nBleiben Sie bitte ruhig liegen.','center','center',P.instr.color, P.instr.wrap, [], [], 3);
            Screen('flip', fenster1);
            tmp.pause_key = 0;
            while tmp.pause_key == 0
                [tmp.pause_keyIsDown, tmp.pause_secs, tmp.pause_keyCode] = KbCheck;
                if tmp.pause_keyIsDown == 1
                    tmp.pause_which_key = find(tmp.pause_keyCode==1,1,'first');
                    % here, if '+' pressed then continue
                    if tmp.pause_which_key == 187
                        tmp.pause_key = 1;
                    end
                end
            end
            % a little screen to say we are starting very soon
            if P.scanner == 0
                agk_gleich_gehts_los_screen(fenster1,1,P)
            elseif P.scanner == 1
                agk_gleich_gehts_los_screen(fenster1,[],P) % no duration indicated, so WaitTrigger has to do it
                P.t.triggerscannertpostpause = WaitForMRITrigger(MRITriggerCode, NumInitialfMRITriggers, []); % last input variable "display" I don't understand
                % HERE USUALLY A FIXATION CROSS
                WaitSecs(10);
            end
        end
        
    end
    
    WaitSecs(0.1);
    
    % MARKER 'END OF EXPERIMENT' 10ms
    if P.physio == 1
        IOPort('ConfigureSerialPort', markcom, 'DTR=0'); % marker-Pin an
        WaitSecs(0.01);
        IOPort('ConfigureSerialPort', markcom, 'DTR=1'); % marker-Pin aus
    end
    % record time
    P.t.fin_instr = GetSecs - P.t.start_exp;
    
    %% terminate physiological recording
    
    % write physiological data
    % zurück gehen
    
    % record time
    P.t.fin_phys = GetSecs - P.t.start_exp;
    
    if P.physio == 1
        % Anhalten der Aufzeichnung der Physiodaten
        stop(AI); % man muss die AD wandler Aufzeichnung beenden
        
        % Holen der Physiodaten
        SAcq = get(AI,'SamplesAcquired');  % schaut, wieviele samples man aufgezeichnet hat
        phys.daten = getdata(AI,SAcq);  % und holt diese Anzahl an Daten aus AI und übergibt sie an die structure "phys" - hier den Unterpunkt "daten"
        phys.EDAfactor = str2double(P.vp.vfaktoreda);  % speichere noch den EDAfactor
        phys.VP = P.vp.num;          % und VP nummer
        phys.samplerate = AISR;
        
        % Speichern der Physiodaten
        tmp.old_pwd = pwd;
        cd(cur.path.vp)
        save(['phys_' P.vp.num],'phys');
        cd(tmp.old_pwd);
        IOPort('CloseAll');
    end
    
    % % Outputdatei neu anlegen und öffnen
    % % 'at' bedeutet eine neue Datei anlegen
    % % 'at' wenn Datei schon da, dann wird attached
    % % \t ist Tabulator
    % % \n Zeilenumbruch
    % % es ist meist gut alles als String rauszuschreiben, das ist einfacher
    % % --> nutzen der num2str-Funktion
    
    fprintf(fileID_demo, [P.vp.num '\t' num2str(P.vp.age) '\t' P.vp.sex '\t' P.vp.bildung '\n']);
    fclose(fileID_demo);
    
    for ii=1:length(P.cur.choice)
        tmp.rt     = num2str(P.cur.rt(ii));
        tmp.gain   = P.gain.strings(P.cur.gamble{ii}(1));
        tmp.loss   = P.loss.strings(P.cur.gamble{ii}(2));
        tmp.choice = num2str(P.cur.choice(ii));
        tmp.cat    = num2str(P.cur.cat(ii));
        tmp.side   = num2str(P.cur.side(ii));
        tmp.st_dur = num2str(P.cur.stim_dur_corr(ii));
        % In Datei schreiben
        fprintf(fileID, [tmp.gain{1} '\t' tmp.loss{1} '\t' tmp.choice '\t' tmp.rt '\t' tmp.cat '\t' tmp.side '\t' tmp.st_dur '\n']);
    end
    fclose(fileID);
    
    % save P
    tmp.old_pwd = pwd;
    cd(cur.path.vp)
    save(['P_' P.vp.num],'P')
    cd(tmp.old_pwd)
    
    %% calculate payout
    P = calc_payout_BGG(P);
    
    
    
    %% Bildererkennungsaufgabe
    [P,stimuli,tmp] = agk_pic_recognition_task(fenster1,P,stimuli,cur,5,tmp);
    
    % add the picrec payout
    new_vec=[];
    for ii = 1:length(P.picrec.choice)
        if P.picrec.choice(ii) == 2
            new_vec(ii) = 0;
        else
            new_vec(ii) = P.picrec.choice(ii);
        end
    end
    P.picrec.choice = new_vec;
    cur.gain = sum((P.picrec.true' == P.picrec.choice)*P.picrec.pos_gain) + sum((P.picrec.true' ~= P.picrec.choice)*P.picrec.pos_gain*(-1));
    % disp(['Final payout is... ' num2str(P.final_payout)])
    P.picrec.gain = cur.gain;
    
    %% Schlussinstruktion
    % using instruction textsize
    Screen('TextSize',fenster1,round(P.textsize*P.textsize_ins_f));
    
    P.clock.geschafft = fix(clock);
    
    DrawFormattedText(fenster1,'Geschafft! Danke für Ihre Teilnahme.', 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], 3);
    Screen('flip', fenster1);
    
    % save P
    tmp.old_pwd = pwd;
    cd(cur.path.vp)
    save(['P_' P.vp.num],'P')
    cd(tmp.old_pwd)
    
    WaitSecs(2);
    Screen('CloseAll');
    ShowCursor
    sca
    
    %% restore the search path
    path(cur.path.org)
    
    % record time and date
    P.clock.end = fix(clock);
    
end
