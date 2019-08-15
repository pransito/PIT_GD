% mk dir function which checks first if the to be made directory already
% exists; only if not it will create one; otherwise will give message and
% do nothing

function message = agk_mkdir_ex(parent_dir,new_dir)
if exist ([parent_dir filesep new_dir],'dir')
    message='The to-be-created directory already exists. I''ll pass';
    disp(message)
else
    mkdir(parent_dir,new_dir)
    message='Ok. Directory created.';
end
end