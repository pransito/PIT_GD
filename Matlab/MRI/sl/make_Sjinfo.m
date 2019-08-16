% make a Sjinfo mat
cur_home   = ['S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\' ...
              'Adlershof\Daten\PDT\pilot'];
cd(cur_home)
T                      = readtable('info_mri_selection.csv', ...
                                   'Delimiter','\t');
Sjinfo.KAP.STID        = T.subject;
Sjinfo.KAP.GROUP       = T.group;
Sjinfo.KAP.SMOKE       = T.smoking_ftdt;
Sjinfo.KAP.EDUYRSSUM   = T.edu_years_sum;

% save it
save('Sjinfo.mat','Sjinfo')




