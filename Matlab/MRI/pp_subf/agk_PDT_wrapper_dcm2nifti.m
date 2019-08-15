% function to use the dcm2nifti tool by Xiangrui Li on the PDT data
function [error_msg] = agk_PDT_wrapper_dcm2nifti(cur_folder,which_folders)
%% get the right folders to convert

disp(['Running ' cur_folder ' now.'])

% folders...
cd(cur_folder)
cd('MRT')
tmp = cellstr(ls('1*'));
cd(tmp{1})
folders_to_convert = {};
for ii = 1:length(which_folders)
    tmp = cellstr(ls([which_folders{ii}]));
    folders_to_convert = [folders_to_convert;cellstr(tmp)];
end
what_folders = [];
for ii = 1:length(folders_to_convert)
    if isdir(folders_to_convert{ii})
        what_folders = [what_folders,ii];
    end
end
folders_to_convert = folders_to_convert(what_folders);

% attention: if any MoCoSeries is there then only that will be converted
tmp   = strfind(folders_to_convert,'MoCoSeries');
there = sum(cell2mat(tmp));
if there
    tmp   = strfind(folders_to_convert,'epi');
    where_epi = [];
    for ll = 1:length(tmp)
        where_epi = [where_epi;isempty(tmp{ll})];
    end
    folders_to_convert = folders_to_convert(logical(where_epi));
end

% check if in any case the MoCo Series is not as long as the Epi-Series
which_folders_me = {'*epi*','*MoCoSeries'};
folders_to_convert_me = {};
for ii = 1:length(which_folders_me)
    tmp = cellstr(ls([which_folders_me{ii}]));
    folders_to_convert_me = [folders_to_convert_me;cellstr(tmp)];
end
what_folders_me = [];
for ii = 1:length(folders_to_convert_me)
    if isdir(folders_to_convert_me{ii})
        what_folders_me = [what_folders_me,ii];
    end
end
folders_to_convert_me = folders_to_convert_me(what_folders_me);

tmp   = strfind(folders_to_convert_me,'MoCoSeries');
tmp_em = [];
for kk = 1:length(tmp)
    tmp_em(kk) = isempty(tmp{kk});
end

mocos = folders_to_convert_me(tmp_em == 0);
epis  = folders_to_convert_me(tmp_em == 1); 

for kk = 1:length(epis)
    chome = pwd;
    cd(epis{kk})
    nepis = length(cellstr(ls()));
    cd(chome)
    cd(mocos{kk})
    nmocos = length(cellstr(ls()));
    
    if nmocos ~= nepis
        error_msg{kk,1} = ['The subject ' cur_folder ' series ' mocos{kk} '...does not match number of epis!'];
        disp(error_msg{kk,1}) 
    else
        error_msg{kk,1} = ['The subject ' cur_folder ' series ' mocos{kk} '...matches number of epis!'];
        disp(error_msg{kk,1}) 
    end
    cd(chome)
end


% check if any series is too short
if there
    tmp = strfind(folders_to_convert,'MoCoSeries');
else
    tmp = strfind(folders_to_convert,'epi');
end

do_conv = [];
for ii = 1:length(tmp)
    cur_home = pwd;
    if isempty(tmp{ii})
        do_conv{ii} = 1;
    else
        cd(folders_to_convert{ii})
        if length(cellstr(ls())) < 240 
            do_conv{ii} = 0;
        else
            do_conv{ii} = 1;
        end
    end
    cd(cur_home)
end
do_conv = logical(cell2mat(do_conv));
folders_to_convert = folders_to_convert(do_conv);

%% do the conversion
cur_path = pwd;
cd('..')
agk_mkdir_ex(pwd,'NIFTI');
cd('NIFTI');
cur_path_nifti = pwd;
for ii = 1:length(folders_to_convert)
    cur_src = fullfile(cur_path,folders_to_convert{ii});
    cd(cur_path_nifti);
    agk_mkdir_ex(pwd,folders_to_convert{ii})
    
    % check if conversion has happened already
    cd(folders_to_convert{ii});
    fnames_cv = spm_select('FPList',pwd,'\.nii');
    if ~isempty(fnames_cv)
        error_msg{ii,2} = ['The subject ' cur_folder ' series ' folders_to_convert{ii} '... is already converted!'];
        disp(error_msg{ii,2})
        disp('I will continue to next dcm folder.')
        continue
    end
    
    cur_tar = fullfile(cur_path_nifti,folders_to_convert{ii});
    outFormat = '3D.nii';
    MoCoOption = 0;
    dicm2nii(cur_src, cur_tar, outFormat,MoCoOption)
    error_msg{ii,2} = ['The subject ' cur_folder ' series ' folders_to_convert{ii} '... has been converted sucessfully!'];
    disp(error_msg{ii,2})
end

end