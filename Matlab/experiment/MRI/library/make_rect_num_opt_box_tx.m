function [rectLA_ins_screen] = make_rect_num_opt_box_tx(w,rect1,P,tmp,opt_screen,side,gamble)

rectLA_ins_screen=Screen('OpenOffscreenWindow',w,[0 0 0 0],rect1);
% set text properties
Screen('TextFont',rectLA_ins_screen,P.textfont);
Screen('TextSize',rectLA_ins_screen,round(P.textsize*P.textsize_opt_f));
Screen('TextStyle',rectLA_ins_screen,P.textstyle);

% draw rects
Screen('FillRect', rectLA_ins_screen,P.rectLA.color,P.rectLA.centeredL);
Screen('FillRect', rectLA_ins_screen,P.rectLA.color,P.rectLA.centeredR);

% numbers into rectLAs

if side == 0
    % compute appropriate coordinate (upper left) where to pin point text box
    % left
    tmp.x_halfL = P.gain.size{gamble(1)}(1)/2;
    tmp.y_halfL = P.gain.size{gamble(1)}(2)*P.textbox_offset;
    
    cur.x_textL = P.rectLA.centeredL(1)+P.rectLA.size(1)/2-tmp.x_halfL;
    cur.y_textL = P.rectLA.centeredL(2)+P.rectLA.size(2)/2-tmp.y_halfL;
    
    %right
    tmp.x_halfR = P.loss.size{gamble(2)}(1)/2;
    tmp.y_halfR = P.loss.size{gamble(2)}(2)*P.textbox_offset;
    
    cur.x_textR = P.rectLA.centeredR(1)+P.rectLA.size(1)/2-tmp.x_halfR;
    cur.y_textR = P.rectLA.centeredR(2)+P.rectLA.size(2)/2-tmp.y_halfR;
    
    DrawFormattedText(rectLA_ins_screen,P.gain.strings{gamble(1)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
    DrawFormattedText(rectLA_ins_screen,P.loss.strings{gamble(2)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
    
else
    tmp.x_halfL = P.loss.size{gamble(2)}(1)/2;
    tmp.y_halfL = P.loss.size{gamble(2)}(2)*P.textbox_offset;
    
    cur.x_textL = P.rectLA.centeredL(1)+P.rectLA.size(1)/2-tmp.x_halfL;
    cur.y_textL = P.rectLA.centeredL(2)+P.rectLA.size(2)/2-tmp.y_halfL;
    
    %right
    tmp.x_halfR = P.gain.size{gamble(1)}(1)/2;
    tmp.y_halfR = P.gain.size{gamble(1)}(2)*P.textbox_offset;
    
    cur.x_textR = P.rectLA.centeredR(1)+P.rectLA.size(1)/2-tmp.x_halfR;
    cur.y_textR = P.rectLA.centeredR(2)+P.rectLA.size(2)/2-tmp.y_halfR;
    
    DrawFormattedText(rectLA_ins_screen,P.loss.strings{gamble(2)}, cur.x_textL, cur.y_textL,[0 0 0 255], [], [], [], 3);
    DrawFormattedText(rectLA_ins_screen,P.gain.strings{gamble(1)}, cur.x_textR, cur.y_textR,[0 0 0 255], [], [], [], 3);
end

% Draw options
Screen('DrawTexture',rectLA_ins_screen,opt_screen)
% Draw yellow box
Screen('FrameRect', rectLA_ins_screen, [255 255 0], tmp.textbounds{2}, P.opt.frame_pt);

end

