% agk_emed_generate_masks_from_atlas.m
% This script generate mask files from any atlases you prefer.
% K. Nemoto 25 April 2015
% edited by Alexander Genauck, March, 2017

% when using AAL for the LA study use e.g. these search terms:
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

% when using spm12 labels_Neuromorphometrics.xml atlas use e.g.
% these terms:
%     anat_region_list = {'Amygdala', ...
%         'Caudate', ...
%         'cingulate gyrus', ...
%         'middle frontal gyrus', ...
%         'medial frontal cortex', ...
%         'Brain Stem', ...
%         'anterior insula', ...
%         'Putamen'};

function [] = agk_emed_generate_masks_from_atlas(cur_atlas, ...
    anat_region_list,dest_folder)

mkdir(dest_folder);
cd(dest_folder);
mkdir('masks');
cd('masks');
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
    disp(['I am at region number... ', ...
        num2str(i), 'of ', num2str(size(S,2))])
    fname=strcat(S{i},'.nii');
    VM=spm_atlas('mask',xA,S{i});
    VM.fname=fname;
    disp(['I found and write region... ', fname])
    spm_write_vol(VM,spm_read_vols(VM));
end