% function based on twu_make_pub_table
% expects the right-click saved table from the SPM output (FWE corr table)
% main function: will add labels

function agk_make_pub_table(cur_file)

% atlas is set
cur_atlas_1   = 'C:\Program Files\spm12\tpm\labels_Neuromorphometrics.xml';
cur_atlas_2   = 'C:\Program Files\spm12\tpm\AAL.xml';
xA_1=spm_atlas('load',cur_atlas_1);
xA_2=spm_atlas('load',cur_atlas_2);

% first reading in the SPM output (Excel file)
[cp,cf,ce] = fileparts(cur_file);
f          = [cf ce];
p          = cp;
[d,t]      = xlsread(fullfile(p,f));

% now looking at coordinates at getting the labels
cur_labels_1 = {};
cur_labels_2 = {};
for ii = 1:size(d,1)
    
    cur_coord    = d(ii,[12:14]);
    cur_labels_1{ii} = spm_atlas('query',xA_1,cur_coord');
    cur_labels_2{ii} = spm_atlas('query',xA_2,cur_coord');
end


% now casting to cell
d_cell = {};
for ii = 1:size(d,1)
    for jj = 1:size(d,2)
        if isnan(d(ii,jj))
            d_cell{ii,jj} = ''; 
        else
            cur_num = d(ii,jj);
            cur_num = round((cur_num*1000))/1000;
            d_cell{ii,jj} = num2str(cur_num);
        end
    end
end
complete_cell = [d_cell,cur_labels_1',cur_labels_2'];
t = [t,{'','';'Neuromorphometrics SPM12 Label','AAL Label'}];
t{1,12} = 'MNI';
t{1,13} = 'MNI';
t{1,14} = 'MNI';
t{2,12} = 'x {mm}';
t{2,13} = 'y {mm}';
t{2,14} = 'z {mm}';
complete_cell = [t;complete_cell];

% write the xls
[cp,cf,ce] = fileparts([p filesep f]);
cd(p)
agk_mkdir_ex(pwd,'labeled');
xlswrite([cp filesep 'labeled' filesep cf '_labeled' ce],complete_cell);

