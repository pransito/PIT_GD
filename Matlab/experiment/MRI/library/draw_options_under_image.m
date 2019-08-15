% draw the options under image; left to right or right to left
function [tmp] = draw_options_under_image(cur_side,P,tmp,fenster1)
if cur_side == 0
    kk = 1;
elseif cur_side == 1
    kk = 2;
end

[tmp.nx,tmp.ny,tmp.textbounds{1}] = DrawFormattedText(fenster1,P.opt.str{kk,1}, P.opt.begin.x{kk},...
    P.opt.begin.y,P.instr.color, [], [], [], 3);
for jj = 2:4
    [tmp.nx,tmp.ny,tmp.textbounds{jj}] = DrawFormattedText(fenster1,P.opt.str{kk,jj}, tmp.textbounds{jj-1}(3)+P.opt.space,...
        P.opt.begin.y,P.instr.color, [], [], [], 3);
end
% prepare for the yellow frame around chosen option
for jj = 1:4
    tmp.textbounds{jj}(1) = tmp.textbounds{jj}(1)-P.opt.enlarge;
    tmp.textbounds{jj}(3) = tmp.textbounds{jj}(3)+P.opt.enlarge;
    tmp.ysize = tmp.textbounds{jj}(4) - tmp.textbounds{jj}(2);
    tmp.textbounds{jj}(4) = tmp.textbounds{jj}(2) + tmp.ysize*P.textbox_offset_yellow;
    tmp.textbounds{jj}(2) = tmp.textbounds{jj}(2)-P.opt.enlarge;
    tmp.textbounds{jj}(4) = tmp.textbounds{jj}(4)+P.opt.enlarge;
end
end