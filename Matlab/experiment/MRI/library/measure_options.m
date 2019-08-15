% options measuring
% kk is direction (1 is left to right, 2, is other way round)

%% options for gambling task 
for kk = 1:2
    
    % use offscreen window to measure the position of options text
    [tmp.nx,tmp.ny,P.opt.rects{kk,1}] = DrawFormattedText(fenster1_off,P.opt.str{kk,1}, 0,...
        0,P.instr.color, [], [], [], P.instr.vspace);
    for jj = 2:4
        [tmp.nx,tmp.ny,P.opt.rects{kk,jj}] = DrawFormattedText(fenster1_off,P.opt.str{kk,jj}, P.opt.rects{kk,jj-1}(3)+P.opt.space,...
            P.opt.begin.y,P.instr.color, [], [], [], P.instr.vspace);
    end
    
    % Where to put options: x
    P.opt.begin.x{kk} = P.xCenter - (P.opt.rects{kk,end}(3) - P.opt.rects{kk,1}(1))/2;
    
    % Close and open offscreen window
    Screen('Close', fenster1_off)
    if P.scanner == 1
        [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color);
    else
        [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color,P.Screen.rect);
    end
    Screen('TextFont',fenster1_off,P.textfont);
    Screen('TextSize',fenster1_off,P.textsize);
    Screen('TextStyle',fenster1_off,P.textstyle);
    
    % Open an off-screen window for the options...
    off.opt.color = [0 0 0 0];
    if P.scanner == 1
        off.opt.screen=Screen(P.screenpointer,'OpenOffscreenWindow',off.opt.color);
    else
        off.opt.screen=Screen(P.screenpointer,'OpenOffscreenWindow',off.opt.color,P.Screen.rect);
    end
    Screen('TextFont',off.opt.screen,P.textfont);
    Screen('TextSize',off.opt.screen,round(P.textsize*P.textsize_opt_f));
    Screen('TextStyle',off.opt.screen,P.textstyle);
    
    % draw the options in off screen
    [tmp.nx,tmp.ny,tmp.textbounds{1}] = DrawFormattedText(off.opt.screen,P.opt.str{kk,1}, P.opt.begin.x{kk},...
        P.opt.begin.y,P.instr.color, [], [], [], 3);
    for jj = 2:4
        [tmp.nx,tmp.ny,tmp.textbounds{jj}] = DrawFormattedText(off.opt.screen,P.opt.str{kk,jj}, tmp.textbounds{jj-1}(3)+P.opt.space,...
            P.opt.begin.y,P.instr.color, [], [], [], 3);
    end
    for jj = 1:4
        tmp.textbounds{jj}(1) = tmp.textbounds{jj}(1)-P.opt.enlarge;
        tmp.textbounds{jj}(3) = tmp.textbounds{jj}(3)+P.opt.enlarge;
        tmp.ysize = tmp.textbounds{jj}(4) - tmp.textbounds{jj}(2);
        tmp.textbounds{jj}(4) = tmp.textbounds{jj}(2) + tmp.ysize*P.textbox_offset_yellow;
    end
    
    % use offscreen window to measure the position of options text
    [tmp.nx,tmp.ny,P.opt.rects{kk,1}] = DrawFormattedText(fenster1_off,P.opt.str{kk,1}, P.opt.begin.x{kk},...
        P.opt.begin.y,P.instr.color, [], [], [], 3);
    for jj = 2:4
        [tmp.nx,tmp.ny,P.opt.rects{jj}] = DrawFormattedText(fenster1_off,P.opt.str{kk,jj}, P.opt.rects{kk,jj-1}(3)+P.opt.space,...
            P.opt.begin.y,P.instr.color, [], [], [], 3);
    end
    
end

%% options for pic rec task
% Close and open offscreen window
Screen('Close', fenster1_off)
if P.scanner ==1
    [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color);
else
    [fenster1_off,rect1_off]=Screen(P.screenpointer,'OpenOffscreenWindow',P.screen.color,P.Screen.rect);
end
Screen('TextFont',fenster1_off,P.textfont);
Screen('TextSize',fenster1_off,P.textsize);
Screen('TextStyle',fenster1_off,P.textstyle);

% use offscreen window to measure the position of options text
[tmp.picrec.nx,tmp.picrec.ny,P.opt.picrec.rects{1}] = DrawFormattedText(fenster1_off,P.opt.picrec.str{1}, 0,...
    0,P.instr.color, [], [], [], P.instr.vspace);
for jj = 2:length(P.opt.picrec.str)
    [tmp.picrec.nx,tmp.picrec.ny,P.opt.picrec.rects{jj}] = DrawFormattedText(fenster1_off,P.opt.picrec.str{jj}, P.opt.picrec.rects{jj-1}(3)+P.opt.space,...
        P.opt.begin.y,P.instr.color, [], [], [], P.instr.vspace);
end

% where to put options: x
P.opt.picrec.begin.x = P.xCenter - (P.opt.picrec.rects{end}(3) - P.opt.picrec.rects{1}(1))/2;