%% calibrate the text-boxes combinations
% calculate the sizes of picture boxes
% calculate the sizes of LA boxes
% calculate the appropriate text sizes for the numbers

% supervision variables
P.calib.text.correct = 0;
P.calib.text.grad    = 0;

P.Screen.rect = [0 0 P.Screen.breite*P.Screen.factor P.Screen.hoehe*P.Screen.factor];
[fenster1,rect1]=Screen('OpenWindow',0,[0 0 0],P.Screen.rect);

% allow fourth color number indicate transparency
Screen('BlendFunction', fenster1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% (Formatierung gilt f�r gesamten Onscreen; Onscreen-Fenster muss dazu ge�ffnet sein)
Screen('TextFont',fenster1,P.textfont);
Screen('TextSize',fenster1,P.textsize);
Screen('TextStyle',fenster1,P.textstyle);

% read in one stimulus (because they are all the same size anyways)
% all one bucket, die Kategorien gehen aus den Namen hervor
cd(cur_path.pic);
stimuli.names = ls('*.jpg');
for ii = 1:1
    stimuli.pics{ii} = imread([pwd '\' stimuli.names(ii,1:end)]);
end

% prepare the LA boxes
% prepare the rectangles for the LA task
stimuli.size=size(stimuli.pics{1});
P.rectLA.size = [0 0 stimuli.size(2)/4 stimuli.size(1)/4];
% Get the centre coordinate of the window
[P.xCenter, P.yCenter] = RectCenter(rect1);
P.rectLA.centeredL = CenterRectOnPointd(P.rectLA.size, P.xCenter-1*(stimuli.size(2)/4), P.yCenter);
P.rectLA.centeredR = CenterRectOnPointd(P.rectLA.size, P.xCenter+1*(stimuli.size(2)/4), P.yCenter);

%% initialize the correct variable (are we in correct or incorrect mode?)
% get the sizes of the numbers when written
for ii=1:length(P.gain.strings)
    tmp_string=P.gain.strings{ii};
    tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
    Screen(tmp_woff,'TextFont',P.textfont)  ;
    Screen(tmp_woff,'TextSize',P.textsize)  ;
    Screen(tmp_woff,'TextStyle',P.textstyle);
    textbounds=TextBounds(tmp_woff,tmp_string);
    Screen(tmp_woff,'Close');
    P.gain.bounds{ii} = textbounds;
    
    % for debugging
    tmp_rect = CenterRectOnPointd(textbounds, P.xCenter, P.yCenter);
    Screen('FillRect', fenster1,P.rectLA.color,tmp_rect);
    DrawFormattedText(fenster1,tmp_string,'center','center',[170 170 170], [], [], [], 3);
    Screen('flip', fenster1);
    pause
    
    P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
end
for ii=1:length(P.loss.strings)
    tmp_string=P.loss.strings{ii};
    tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
    Screen(tmp_woff,'TextFont',P.textfont)  ;
    Screen(tmp_woff,'TextSize',P.textsize)  ;
    Screen(tmp_woff,'TextStyle',P.textstyle);
    textbounds=TextBounds(tmp_woff,tmp_string);
    Screen(tmp_woff,'Close');
    P.loss.bounds{ii} = textbounds;
    P.loss.size{ii} = [P.loss.bounds{ii}(3)-P.loss.bounds{ii}(1),P.loss.bounds{ii}(4)-P.loss.bounds{ii}(2)];
end

% check whether they don't bleed over boxes
% size of the rectLA
P.rectLA.size = [P.rectLA.centeredL(3) - P.rectLA.centeredL(1), P.rectLA.centeredL(4) - P.rectLA.centeredL(2)];

for ii=1:length(P.gain.bounds)
    if P.gain.size{ii}(1) >= P.rectLA.size(1) | P.loss.size{ii}(1) >= P.rectLA.size(1)
        P.calib.text.correct = 0;
        break
    else
        P.calib.text.correct = 1;
    end
    if P.gain.size{ii}(2) >= P.rectLA.size(2) | P.loss.size{ii}(2) >= P.rectLA.size(2)
        P.calib.text.correct = 0;
        break
    end
end

%% change text size according to value of the "correct" variable
while P.calib.text.grad == 0
    if P.calib.text.correct == 0
        P.textsize=P.textsize-1;
        Screen('TextSize',fenster1,P.textsize);
    else
        P.textsize=P.textsize+1;
        Screen('TextSize',fenster1,P.textsize);
    end
    
    % compute new sizes of boxes
    % get the sizes of the numbers when written
    for ii=1:length(P.gain.strings)
        tmp_string=P.gain.strings{ii};
        tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
        Screen(tmp_woff,'TextFont',P.textfont)  ;
        Screen(tmp_woff,'TextSize',P.textsize)  ;
        Screen(tmp_woff,'TextStyle',P.textstyle);
        textbounds=TextBounds(tmp_woff,tmp_string);
        Screen(tmp_woff,'Close');
        P.gain.bounds{ii} = textbounds;
        P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
    end
    for ii=1:length(P.loss.strings)
        tmp_string=P.loss.strings{ii};
        tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
        Screen(tmp_woff,'TextFont',P.textfont)  ;
        Screen(tmp_woff,'TextSize',P.textsize)  ;
        Screen(tmp_woff,'TextStyle',P.textstyle);
        textbounds=TextBounds(tmp_woff,tmp_string);
        Screen(tmp_woff,'Close');
        P.loss.bounds{ii} = textbounds;
        P.loss.size{ii} = [P.loss.bounds{ii}(3)-P.loss.bounds{ii}(1),P.loss.bounds{ii}(4)-P.loss.bounds{ii}(2)];
    end
    
    % check for bleed over
    for ii=1:length(P.gain.bounds)
        % check for wrong size (x)
        if P.gain.size{ii}(1) >= P.rectLA.size(1) | P.loss.size{ii}(1) >= P.rectLA.size(1)
            tmp_corr_x = 0;
        else
            tmp_corr_x = 1;
        end
        % check for wrong size (y)
        if P.gain.size{ii}(2) >= P.rectLA.size(2) | P.loss.size{ii}(2) >= P.rectLA.size(2)
            tmp_corr_y = 0;
        else
            tmp_corr_y = 1;
        end
        if tmp_corr_x == 1 && tmp_corr_y == 1
            tmp_corr = 1;
        else
            tmp_corr = 0;
        end
        % check for changes (gradient) in correct variable
        % earlier correct, now wrong (exactly one step too big)
        if P.calib.text.correct == 1 && tmp_corr == 0
            P.calib.text.correct = 0; P.calib.text.grad = 1;
            break
        end
        % earlier it was wrong, now it is correct
        if P.calib.text.correct == 0 && tmp_corr == 1
            P.calib.text.correct = 1; P.calib.text.grad = -1;
            break
        end
        if tmp_corr == 0
            P.calib.text.correct = 0;
        else
            P.calib.text.correct = 1;
        end
    end
end

if P.calib.text.grad == 1
    P.textsize = P.textsize-1;
    Screen('TextSize',fenster1,P.textsize);
else
    P.textsize = P.textsize-0;
    Screen('TextSize',fenster1,P.textsize);
end

% compute new sizes of boxes
% get the sizes of the numbers when written
for ii=1:length(P.gain.strings)
    tmp_string=P.gain.strings{ii};
    tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
    Screen(tmp_woff,'TextFont',P.textfont)  ;
    Screen(tmp_woff,'TextSize',P.textsize)  ;
    Screen(tmp_woff,'TextStyle',P.textstyle);
    textbounds=TextBounds(tmp_woff,tmp_string);
    Screen(tmp_woff,'Close');
    P.gain.bounds{ii} = textbounds;
    P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
end
for ii=1:length(P.loss.strings)
    tmp_string=P.loss.strings{ii};
    tmp_woff=Screen(fenster1,'OpenOffscreenWindow',[],[0 0 3*P.textsize*length(tmp_string) 2*P.textsize]);
    Screen(tmp_woff,'TextFont',P.textfont)  ;
    Screen(tmp_woff,'TextSize',P.textsize)  ;
    Screen(tmp_woff,'TextStyle',P.textstyle);
    textbounds=TextBounds(tmp_woff,tmp_string);
    Screen(tmp_woff,'Close');
    P.loss.bounds{ii} = textbounds;
    P.loss.size{ii} = [P.loss.bounds{ii}(3)-P.loss.bounds{ii}(1),P.loss.bounds{ii}(4)-P.loss.bounds{ii}(2)];
end

sca
