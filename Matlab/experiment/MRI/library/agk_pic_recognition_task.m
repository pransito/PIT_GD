% input num is how many should be known (num) and how many unknown (num)
function [P,stimuli,tmp] = agk_pic_recognition_task(fenster1,P,stimuli,cur,num,tmp)
% using instruction textsize
Screen('TextSize',fenster1,round(P.textsize*P.textsize_ins_f));


DrawFormattedText(fenster1,'Geschafft!\nEs folgt nun die Aufgabe,\n bei der Sie die Bilder wiedererkennen sollen.', 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], 3);
Screen('flip', fenster1);
WaitSecs(4)
DrawFormattedText(fenster1,'Bei den folgenden Bildern sollen Sie immer angeben,\n ob Sie das Bild eben im Experiment\n gesehen haben (bekannt) oder nicht (neu).', 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], 3);
Screen('flip', fenster1);
WaitSecs(6)
DrawFormattedText(fenster1,'Für "bekannt" nutzen Sie Taste 1 (Zeigefinger)\n und für "unbekannt" nutzen Sie Taste 2 (Mittelfinger).', 'center' , 'center' ,P.instr.color, P.instr.wrap, [], [], 3);
Screen('flip', fenster1);
WaitSecs(5)

% stimuli from experiment (5)
stimuli.picrec.true = stimuli.pics(randsample(length(stimuli.pics),num));

% distr stimuli read in (5)
cd(cur.path.pwd)
cd(cur.path.pic)
cd(cur.path.pic_dis)
stimuli.pic_dis.names = ls('*.jpg');
tmp_names=cellstr(stimuli.pic_dis.names);
stimuli.pic_dis.names = tmp_names(randsample(length(tmp_names),num));
for ii = 1:length(stimuli.pic_dis.names)
    stimuli.pic_dis.pics{ii} = imread([pwd '\' char(stimuli.pic_dis.names(ii))]);
end

% bind the two pics vectors
cur.pics = [stimuli.pic_dis.pics';stimuli.picrec.true'];
cur.true = [zeros(num,1);ones(num,1)];
cur.leng = length(cur.pics);
cur.rand = randperm(cur.leng);
cur.pics = cur.pics(cur.rand);
cur.true = cur.true(cur.rand);
% record what are the true pics now for later check against participant's
% choices
P.picrec.true = cur.true;

% Display
for ii = 1: length(cur.pics)
    P.tx=Screen('MakeTexture', fenster1, cur.pics{ii});
    Screen('DrawTexture',fenster1,P.tx);
    tmp = draw_options_under_image_picrec(P,tmp,fenster1);
    Screen('flip', fenster1);
    record_choice_picrec
end

% using instruction textsize
% resetting
Screen('TextSize',fenster1,round(P.textsize));



end