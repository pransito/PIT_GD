% draw the two options under pic recognition pic
function [tmp] = draw_options_under_image_picrec(P,tmp,fenster1)
% using normal textsize
Screen('TextSize',fenster1,round(P.textsize));

[tmp.picrec.nx,tmp.picrec.ny,tmp.picrec.textbounds{1}] = DrawFormattedText(fenster1,P.opt.picrec.str{1}, P.opt.picrec.begin.x,...
    P.opt.begin.y,P.instr.color, [], [], [], 3);
for jj = 2:length(P.opt.picrec.str)
    [tmp.picrec.nx,tmp.picrec.ny,tmp.picrec.textbounds{jj}] = DrawFormattedText(fenster1,P.opt.picrec.str{jj}, tmp.picrec.textbounds{jj-1}(3)+P.opt.space,...
        P.opt.begin.y,P.instr.color, [], [], [], 3);
end
for jj = 1:length(P.opt.picrec.str)
    tmp.picrec.textbounds{jj}(1) = tmp.picrec.textbounds{jj}(1)-P.opt.enlarge;
    tmp.picrec.textbounds{jj}(3) = tmp.picrec.textbounds{jj}(3)+P.opt.enlarge;
    tmp.picrec.ysize = tmp.picrec.textbounds{jj}(4) - tmp.picrec.textbounds{jj}(2);
    tmp.picrec.textbounds{jj}(4) = tmp.picrec.textbounds{jj}(2) + tmp.picrec.ysize*P.textbox_offset_yellow;
    tmp.picrec.textbounds{jj}(2) = tmp.picrec.textbounds{jj}(2)-P.opt.enlarge;
    tmp.picrec.textbounds{jj}(4) = tmp.picrec.textbounds{jj}(4)+P.opt.enlarge;
end
end
