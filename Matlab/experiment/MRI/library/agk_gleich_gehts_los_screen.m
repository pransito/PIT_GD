function [] = agk_gleich_gehts_los_screen(fenster1,duration,P)
% using instruction textsize
Screen('TextSize',fenster1,round(P.textsize*P.textsize_ins_f));

DrawFormattedText(fenster1,'Gleich geht''s los!', 'center' , 'center' ,P.instr.color,P.instr.wrap,[],[],3);
Screen('flip', fenster1);
if ~isempty(duration)
    WaitSecs(duration)
end

% resetting textsize
Screen('TextSize',fenster1,P.textsize);

end