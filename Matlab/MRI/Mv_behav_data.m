% script to move behav data to google drive
% relevant for MRI behav data

% add the paths
start_up
% path of data to be copied. Has to be adapted possibly
curpt = strcat('E:\Daten\VPPG\MRT\MRT\');  
% location of data to be copied to. Has to be possibly adapted
nwpt  = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten\PDT\MRT';    
att   = 'Behav';
ow    = 0;
ct    = 0;

% find the folders
cd(curpt)
mri_behav_source = cellstr(ls('VPPG0*'));

% go through folders and copy behav data
for ii = 1:length(mri_behav_source)
    vp = mri_behav_source{ii};
    filename1 = fullfile(curpt,vp,att);
    filename2 = fullfile(nwpt,vp);
    
%     % temporary
%     try
%         rmdir(fullfile(filename2,att),'s')
%     catch
%         disp('some error while deleting behav folder')
%     end
%     
    % check if target already there (only if overwrite not allowed)
    ct = agk_mv_behav_data_subf_check_copy(ow,filename1,filename2,ct);

end
disp([num2str(ct) ' behav data sets from MRI cohort available'])