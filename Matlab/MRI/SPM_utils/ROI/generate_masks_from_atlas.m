% generate_masks_from_atlas.m
% This script generate mask files from any atlases you prefer.
% K. Nemoto 25 April 2015
% edited by Alexander Genauck, May, 2015

% when using AAL for the LA study use these search terms:
%     anat_region_list = {'Amygdala', ...
%         'Caudate', ...
%         'Cingulum', ...
%         'Hippocampus', ...
%         'Brainstem', ...
%         'Insula', ...
%         'ParaHippo',...
%         'Parietal_Sup', ...
%         'Midbrain', ...
%         'Substantia Nigra', ...
%         'Frontal'};

% when using spm12 labels_Neuromorphometrics.xml atlas in LA study use
% these terms:
%     anat_region_list = {'Amygdala', ...
%         'Caudate', ...
%         'cingulate gyrus', ...
%         'middle frontal gyrus', ...
%         'medial frontal cortex', ...
%         'Brain Stem', ...
%         'anterior insula', ...
%         'Putamen'};

function [] = generate_masks_from_atlas(cur_atlas, anat_region_list, ...
    dest_folder,out_name,clean_sub_masks)

base_dir = pwd;
agk_mkdir_ex(pwd,'tmp');
cd('tmp');
base_dir = pwd;

% select an atlas
xA=spm_atlas('load',cur_atlas);

% use anat_region_list to pick the regions from the Atlas
all_regions = [];
for ii = 1:length(anat_region_list)
    for jj = 1:length(xA.labels)
        cur_find = strfind(xA.labels(jj).name,anat_region_list{ii});
        if isempty(cur_find)
            cur_find = strfind(xA.labels(jj).name,lower(anat_region_list{ii}));
        end
        if ~isempty(cur_find)
            all_regions = [all_regions; cellstr(xA.labels(jj).name)];
        end
    end
end
S = all_regions';

% GUI-select
% S=spm_atlas('select',xA);

for i = 1:size(S,2)
    disp(['I am at region number... ', num2str(i), 'of ', num2str(size(S,2))])
    fname=strcat(S{i},'.nii');
    VM=spm_atlas('mask',xA,S{i});
    VM.fname=fname;
    disp(['I found and write region... ', fname])
    spm_write_vol(VM,spm_read_vols(VM));
    %     % Ugly try-catch solution to ugly writing problem...
    %     saved = 0;
    %     while saved == 0;
    %         try
    %             disp(['Attempting to write .nii' filename]);
    %             spm_write_vol(VM,spm_read_vols(VM));
    %             saved = 1;
    %         catch
    %             warning('Problem saving, retry saving...')
    %             pause(.5);
    %         end;
    %     end;
end

% now combine all to one mask
all_files = cellstr(ls('*.nii'));
if length(all_files) > 1
    f = 'sum(X)';
    spm_imcalc(all_files,[dest_folder filesep out_name],f,{1});
else
    f = 'i1';
    spm_imcalc(all_files,[dest_folder filesep out_name],f,{0});
end

cd(dest_folder)
% make a 0-1 mask
f = 'i1>0.95';
spm_imcalc(out_name,out_name,f,{0});

cd(dest_folder)
save('all_used_regions.mat','S')
cd(base_dir)

% clean-up
if clean_sub_masks
    for ii=1:length(all_files)
        delete(all_files{ii});
    end
    cd(dest_folder)
    try
        rmdir('tmp','s')
    catch
    end
end

end