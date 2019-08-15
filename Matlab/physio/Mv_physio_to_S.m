% Script to move physio data to S:
src    = 'C:\Users\genaucka\Google Drive\Promotion\VPPG\VPPG_Exchange\Experimente\PDT\Daten';
subf   = {'pilot','POSTPILOT\HC','POSTPILOT\PG','PG'};
trg    = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\Adlershof\Daten\Physio';
report = {};

for ii = 1:length(subf)
    cd(src)
    cd(fullfile(src,subf{ii}));
    all_subs = cellstr(ls('PhysioVP*'));
    
    for jj = 1:length(all_subs)
        cd(all_subs{jj})
        cur_code = strsplit(all_subs{jj},'PhysioVP');
        cur_code = cur_code{2};
        
        % get the physio data and move it
        cur_phys = ['phys_' cur_code '.mat'];
        tmp = ls(cur_phys);
        if isempty (tmp) % no phys found; leave a note
            
            % is there phys data already at target?
            cur_trg_folder = fullfile(trg,subf{ii},['PhysioVP' cur_code]);
            cur_trg_file = fullfile(cur_trg_folder,cur_phys);
            
            if exist(cur_trg_file)
                disp(cur_phys)
                msg    = 'phys data already at target';
                msg_ns = 'skipped note at source';
                msg_nt = 'skipped note at target';
                msg_m  = 'skipped move';
                disp(msg);disp(msg_ns);disp(msg_nt);disp(msg_m)
                cd ..
                continue
            end
            
            msg = [cur_code ': no physdata found'];
            disp(msg);
            res = system('copy NUL no_phys_data_for_this_sub.txt'); % create a note that there is no data
            if res == 0
                msg_ns = 'note at source was successful';
            else
                msg_ns = 'note at source was not successful';
            end
            disp(msg_ns)
            
            cur_trg_folder = fullfile(trg,subf{ii},['PhysioVP' cur_code]);
            mkdir(cur_trg_folder)
            res = system(['copy NUL ' fullfile(cur_trg_folder, 'no_phys_data_for_this_sub.txt')]); % also leave a note at target
            if res == 0
                msg_nt = 'note at target was successful';
            else
                msg_nt = 'note at target was not successful';
            end
            msg_m = 'no moving applicable';
            disp(msg_nt); disp(msg_m);
        else             % phys data found; leave a note where moved to
            msg = [cur_code ': physdata found'];
            disp(msg);
            cur_src_file   = fullfile(pwd, cur_phys);
            cur_trg_folder = fullfile(trg,subf{ii},['PhysioVP' cur_code]);
            
            % leave not
            mkdir(cur_trg_folder)
            cur_trg_file = fullfile(cur_trg_folder,cur_phys);
            res = system(['@echo ' cur_trg_file ' > phys_moved_to.txt']);
            if res == 0
                msg_ns = 'note at source was successful';
            else
                msg_ns = 'note at source was not successful';
            end
            msg_nt = 'note at target not applicable';
            disp(msg_ns); disp(msg_nt);
            
            % moving
            tmp = strsplit(cur_trg_file,'S:\');
            res = system(['move ' '"' cur_src_file '"' ' ' 'S:/' '"' tmp{2} '"']);
            if res == 0
                msg_m = 'move was successful';
            else
                msg_m = 'move was not successful';
            end
            disp(msg_m);
                
        end
       
        report{jj,ii} = [msg ' ' msg_ns ' ' msg_nt ' ' msg_m];
        cd ..
        
    end
    
end