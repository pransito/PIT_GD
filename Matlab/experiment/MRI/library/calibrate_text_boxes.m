%% calibrate the text-boxes combinations
% calculate the sizes of picture boxes
% calculate the sizes of LA boxes
% calculate the appropriate text sizes for the numbers

% supervision variables
P.calib.text.correct = 0;
P.calib.text.grad    = 0;

% open an off-screen (rewrite script to do all in off-screen)
% need to also open an on-screen window for that
% onscreen
if P.scanner
    [fenster1,rect1]=Screen('OpenWindow',P.screenpointer,P.screen.color);
else
    [fenster1,rect1]=Screen('OpenWindow',P.screenpointer,P.screen.color,P.Screen.rect);
end

%offscreen
if P.scanner
    [fenster2_off,rect2_off]=Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color,P.Screen.rect);
else
    [fenster2_off,rect2_off]=Screen('OpenOffscreenWindow',P.screenpointer,P.screen.color);
end
    
% allow fourth color number indicate transparency
Screen('BlendFunction', fenster1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');
Screen('BlendFunction', fenster2_off, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

% (Formatierung gilt für gesamten Onscreen; Onscreen-Fenster muss dazu geöffnet sein)
Screen('TextFont',fenster2_off,'Arial');
Screen('TextSize',fenster2_off,P.textsize); 
Screen('TextStyle',fenster2_off,1);

% read in one stimulus (because they are all the same size anyways)
% all one bucket, die Kategorien gehen aus den Namen hervor
cd(cur.path.pwd);
cd(cur.path.pic);
stimuli.names = ls('*.jpg');
for ii = 1:1
    stimuli.pics{ii} = imread([pwd '\' stimuli.names(ii,1:end)]);
end

% prepare the LA boxes
% prepare the rectangles for the LA task
stimuli.size=size(stimuli.pics{1});
stimuli.size=[stimuli.size(2), stimuli.size(1)];
P.rectLA.size = [0 0 stimuli.size(1)/3 stimuli.size(2)/3];
% Get the centre coordinate of the window
[P.xCenter, P.yCenter] = RectCenter(rect2_off);
P.rectLA.centeredL = CenterRectOnPointd(P.rectLA.size, P.xCenter-1*(stimuli.size(1)/4), P.yCenter);
P.rectLA.centeredR = CenterRectOnPointd(P.rectLA.size, P.xCenter+1*(stimuli.size(1)/4), P.yCenter);

%% initialize the correct variable (are we in correct or incorrect mode?)
% get the sizes of the numbers when written
for ii=1:length(P.gain.strings)
[nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.gain.strings{ii},'center','center',[170 170 170], [], [], [], 3);
P.gain.bounds{ii} = textbounds;
P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
end
for ii=1:length(P.loss.strings)
[nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.loss.strings{ii},'center','center',[170 170 170], [], [], [], 3);
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
        Screen('TextSize',fenster2_off,P.textsize);
    else
        P.textsize=P.textsize+1;
        Screen('TextSize',fenster2_off,P.textsize);
    end
    
    % compute new sizes of boxes
    % get the sizes of the numbers when written
    for ii=1:length(P.gain.strings)
        [nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.gain.strings{ii},'center','center',[170 170 170], [], [], [], 3);
        P.gain.bounds{ii} = textbounds;
        P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
        % don't need to erase
    end
    for ii=1:length(P.loss.strings)
        [nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.loss.strings{ii},'center','center',[170 170 170], [], [], [], 3);
        P.loss.bounds{ii} = textbounds;
        P.loss.size{ii} = [P.loss.bounds{ii}(3)-P.loss.bounds{ii}(1),P.loss.bounds{ii}(4)-P.loss.bounds{ii}(2)];
        % don't need to erase
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
    Screen('TextSize',fenster2_off,P.textsize);
else
    P.textsize = P.textsize-0;
    Screen('TextSize',fenster2_off,P.textsize);
end

% compute new sizes of boxes
% get the sizes of the numbers when written
for ii=1:length(P.gain.strings)
    [nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.gain.strings{ii},'center','center',[170 170 170], [], [], [], 3);
    P.gain.bounds{ii} = textbounds;
    P.gain.size{ii} = [P.gain.bounds{ii}(3)-P.gain.bounds{ii}(1),P.gain.bounds{ii}(4)-P.gain.bounds{ii}(2)];
    % don't need to erase
end
for ii=1:length(P.loss.strings)
    [nx,ny, textbounds] = DrawFormattedText(fenster2_off,P.loss.strings{ii},'center','center',[170 170 170], [], [], [], 3);
    P.loss.bounds{ii} = textbounds;
    P.loss.size{ii} = [P.loss.bounds{ii}(3)-P.loss.bounds{ii}(1),P.loss.bounds{ii}(4)-P.loss.bounds{ii}(2)];
    % don't need to erase
end

Screen('Close', fenster2_off)
    