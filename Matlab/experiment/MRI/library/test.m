% open onscreen window
[fenster1,rect1]=Screen('OpenWindow',0,P.screen.color, P.Screen.rect);
Screen('BlendFunction', fenster1, 'GL_SRC_ALPHA', 'GL_ONE_MINUS_SRC_ALPHA');

rect_num_tx = make_rect_num_tx(fenster1,P.rectLA,rect1,P.gain,P.loss,0,[3 8],P.textbox_offset);


% open offscreen where to collect texture (child of on-screen)
off.gainr.color   = [0 0 0 0];
off.gainr.screen=Screen('OpenOffscreenWindow',fenster1,P.screen.color,P.Screen.rect);

% open offscreen where to copy rectLA to; child of off-screen
% off.gainr.color
off.rectLA_ins.color   = [0 0 0 0];
off.rectLA_ins.screen=Screen('OpenOffscreenWindow',off.gainr.screen,off.gainr.color,P.Screen.rect);
Screen('FillRect', off.rectLA_ins.screen,P.rectLA.color,P.rectLA.centeredL);
Screen('FillRect', off.rectLA_ins.screen,P.rectLA.color,P.rectLA.centeredR);

P.tx = Screen('MakeTexture', fenster1, stimuli.instr_pic);
Screen('DrawTexture', fenster1, P.tx)
Screen('DrawTexture',fenster1,rect_num_tx,[],[0 0 rect1(3)-50 rect1(4)-50])

Screen('flip',fenster1)
