% write new output file for easier access for R
% goes into all the behav folders, gets the P-file and writes a new
% output file to avoid readMat function in R
% (what was missing was the stim name)

%% get all the necessary paths
comp_name = getenv('username');
addpath(['C:\Users\' comp_name filesep 'Google Drive\' ...
    'Promotion\VPPG\VPPG_Exchange\Experimente\PDT\analysis\scripts\' ...
    'Matlab']);
addpath(genpath(['C:\Users\' comp_name '\Google Drive\Library\MATLAB']));

% base directory and other dirs
path_data      = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten';
base_dir       = fullfile(path_data,'PDT\pilot');
base_dir_PG    = fullfile(path_data,'PDT\PG');
base_dir_pp_PG = fullfile(path_data,'PDT\POSTPILOT\PG');
base_dir_pp_HC = fullfile(path_data,'PDT\POSTPILOT\HC');
base_dir_mrt   = fullfile(path_data,'PDT\MRT');

cd(base_dir)
subs = dir('PhysioVP*');
for gg = 1:length(subs)
    subs(gg).name = [base_dir filesep subs(gg).name];
end
cd(base_dir_PG)
subs_PG = dir('Physio*');
for gg = 1:length(subs_PG)
    subs_PG(gg).name = [base_dir_PG filesep subs_PG(gg).name];
end
cd(base_dir_pp_PG)
subs_pp_PG = dir('Physio*');
for gg = 1:length(subs_pp_PG)
    subs_pp_PG(gg).name = [base_dir_pp_PG filesep subs_pp_PG(gg).name];
end
cd(base_dir_pp_HC)
subs_pp_HC = dir('Physio*');
for gg = 1:length(subs_pp_HC)
    subs_pp_HC(gg).name = [base_dir_pp_HC filesep subs_pp_HC(gg).name];
end
cd(base_dir_mrt)
subs_mrt = dir('VPPG0*');
for gg = 1:length(subs_mrt)
    subs_mrt(gg).name = [base_dir_mrt filesep subs_mrt(gg).name ...
        filesep 'PDT'];
end
subs =  [subs;subs_PG;subs_pp_HC;subs_pp_PG;subs_mrt];

%% write output files
h = waitbar(0,'Extracting output...');
steps = length(subs);
for ii = 1:steps
    
    % change into folder and load P
    cd(subs(ii).name)
    try
        load(ls('P_*'))
    catch
        disp(['Could not extract ' subs(ii).name])
        continue
    end
    
    % Output-Datei anlegen
    outputname=[num2str(P.vp.num) '_output_extr.txt'];
    fileID=fopen(outputname,'w');
    
    % erste Zeile Schreiben
    fprintf(fileID, 'gain\t');
    fprintf(fileID, 'loss\t');
    fprintf(fileID, 'choice\t');
    fprintf(fileID, 'rt\t');
    fprintf(fileID, 'cat\t');
    fprintf(fileID, 'side\t');
    fprintf(fileID, 'st_dur \t');
    fprintf(fileID, 'stim \n');
    
    % write all necessary output
    for jj=1:length(P.cur.choice)
        tmp.rt     = num2str(P.cur.rt(jj));
        tmp.gain   = P.gain.strings(P.cur.gamble{jj}(1));
        tmp.loss   = P.loss.strings(P.cur.gamble{jj}(2));
        tmp.choice = num2str(P.cur.choice(jj));
        tmp.cat    = num2str(P.cur.cat(jj));
        tmp.side   = num2str(P.cur.side(jj));
        tmp.st_dur = num2str(P.cur.stim_dur_corr(jj));
        tmp.stim   = strtrim(P.cur.stim{jj});
        % In Datei schreiben
        fprintf(fileID, [tmp.gain{1} '\t' tmp.loss{1} '\t' ...
            tmp.choice '\t' tmp.rt '\t' tmp.cat '\t' tmp.side ...
            '\t' tmp.st_dur '\t' tmp.stim '\n']);
    end
    fclose(fileID);
    
    % output demograph extract
    % Demographie-Datei anlegen
    demographname=[num2str(P.vp.num) '_demograph_extr.txt'];
    fileID_demo=fopen(demographname,'w');
    
    % erste Zeile Schreiben
    fprintf(fileID_demo, 'vpn\t');
    fprintf(fileID_demo, 'age\t');
    fprintf(fileID_demo, 'sex\t');
    fprintf(fileID_demo, 'edu\n');
    
    % Daten schreiben
    fprintf(fileID_demo, [P.vp.num '\t' num2str(P.vp.age) '\t' P.vp.sex '\t' P.vp.bildung '\n']);
    fclose(fileID_demo);
    
    waitbar(ii/steps,h)
end
close(h)