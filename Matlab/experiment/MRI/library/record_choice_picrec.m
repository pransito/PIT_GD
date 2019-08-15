% check which option is chosen during decision time
% KEINE PHYSIO MARKER MEHR!!

% using normal textsize
% resetting
Screen('TextSize',fenster1,round(P.textsize));


tmp.t0_gamble = GetSecs;
% default is: nothing chosen
tmp.reaction=9999;
while GetSecs <= tmp.t0_gamble + P.opt.picrec.dl
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
        if sum(tmp.which_key == P.opt.picrec.kbc)
            
            % record rt and choice and compute iti_corr_time
            tmp.reaction     = 1;
            P.picrec.rt(ii)  = GetSecs-tmp.t0_gamble;
            tmp.t_corr_iti   = (tmp.t0_gamble + P.picrec.rt(ii)) - (tmp.t0_gamble + P.opt.picrec.dl);
            P.picrec.choice(ii) = P.opt.picrec.num(P.opt.picrec.kbc == tmp.which_key);
            
            % Draw the picture and the rectLA again into off screen
            % Draw options and numbers also
            Screen('DrawTexture',fenster1,P.tx);
            [tmp] = draw_options_under_image_picrec(P,tmp,fenster1);
            
            % paint a yellow box around the chosen option into the
            % off-window fenster1_off
            Screen('FrameRect', fenster1, [255 255 0], tmp.picrec.textbounds{P.picrec.choice(ii)}, P.opt.frame_pt);
            
            % LA gamble with chosen option marked
            Screen('flip', fenster1);
            % record the time
            P.t.picrec.stimoff(ii) = GetSecs - P.t.start_exp;
            
            % show the marked option for a while
            WaitSecs(P.instr.slow.time)
            break
        end
    end
end

if tmp.reaction==9999
    
    P.picrec.choice(ii) = 5;
    P.picrec.rt(ii)     = 99999;
    DrawFormattedText(fenster1,P.instr.slow.string, 'center' , 'center' ,P.instr.color, [], [], [], 2);
    Screen('flip', fenster1);
    
    % record time
    P.t.picrec.stimoff(ii) = GetSecs - P.t.start_exp;
    WaitSecs(P.instr.slow.time)
end