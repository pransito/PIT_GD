%%%Miriam_Bewegungsskript 04/09/2013
%%%Wichtig ist, dass Pfade nicht mehr geändert werden.

clear
clc

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%Modify this%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% SITE = [1;2]; %1=Berlin, 2=Dresden
paradigm = [{'TS'}]; %[{'Pav'};{'Pit'};{'TS'}]
Project = ['P2']
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% for where = 1:length(SITE)
    for what = 1:length(paradigm)
%         % die site
%         if where == 1
%             site='\berlin';
%             suffix = 'B';
%         else
%             site='\dresden';
%             suffix = 'DD';
%         end
        
        if strcmp(paradigm{what},'Pav')
            forMRI='pav';
        elseif strcmp(paradigm{what},'Pit')
            forMRI='pit';
        elseif strcmp(paradigm{what},'TS')
            forMRI='2step';
        end
        
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        output_file = ['Movement_' cell2mat(paradigm) '.xls'];
        %data_path   = ['S:\AG\AG-Emotional-Neuroscience-Backup\DFG FOR 1617 LeAD\DATA\20140228\2step'];
        data_path    = ['S:\AG\AG-Emotional-Neuroscience-Backup-III\' Project filesep forMRI]
        %output_path = ['Z:\DFG-For1617\ANALYSIS\preproc_quali_check\RP_check\TS'];
        output_path =  ['Z:\DFG-For1617\ANALYSIS\preproc_quali_check\RP_check\' Project filesep cell2mat(paradigm)]
        savestr = [output_path '\rpdata.mat'];
        
        %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
        clear data
        cd(output_path)
        % list_sub_data_paths = spm_select(inf, 'dir', 'Wähle die Datenordner der Subjects für Bewegungs-Check aus','',  data_path); %%%hier muss dann immer
        %%% --> wenn unterschiedliche lange files geht das nicht
        
        list_sub_data_paths = dir([data_path])
        list_sub_data_paths={list_sub_data_paths.name}
        list_sub_data_paths=list_sub_data_paths(3:end)
        
        fid=fopen(output_file, 'w'); % open output file
        fprintf(fid, 'code\t');
        fprintf(fid, 'x_diff\t y_diff\t z_diff\t pitch_diff\t yaw_diff\t roll_diff\t euklidic_distance\t X_max\t Y_max\t Z_max\t Pitch_max\t Yaw_max\t Roll_max\t x_vol2vol\t y_vol2vol\t z_vol2vol\t pitch_vol2vol\t yaw_vol2vol\t roll_vol2vol\n');
        % fprintf(fid, 'x_diff_run2\t y_diff_run2\t z_diff_run2\t pitch_diff_run2\t yaw_diff_run2\t roll_diff_run2\t euklidic_distance_run2\n');
        
        %Subject und dazugehöriger Pfad mit rp-file
        %
        % fod=fopen(tworuns_file,'w');
        % fprintf(fod, 'code\t');
        
        for sub           = 1:length(list_sub_data_paths)
            s             = strread(list_sub_data_paths{sub}, '%s','delimiter', '\\');
            subjects{sub} = cell2mat(s);
            
            
            
            %Subject in Ausgabedatei schreiben
            %%% Anpassen, jenachdem wie lang data_path ist.
            fprintf(fid, '%s\t', subjects{sub});
            %rp-file Pfad und Datei für jeweiligen run
            %     ed_both_runs = [];
            
            %     for run = 1:1
            %Subject und run in Command Window schreiben
            fprintf('working on %s \n', subjects{sub})
            sub_rp_path = [data_path '\' list_sub_data_paths{sub},'\preprocessing'];   %,  %['run_' num2str(run)]);
            try
            sub_rp_file = spm_select('List', sub_rp_path, '^rp_.*\.txt$');
            %     if size(sub_rp_file,1) == 1
            sub_rp_file_path = fullfile(sub_rp_path, sub_rp_file);
            %rp-file in Command Window schreiben
            fprintf('reading %s \n', sub_rp_file_path)
            %rp_file einlesen
            matrix  = textread(sub_rp_file_path);
            %Für 3x Translation und 3x Rotation einzelne Vektoren bilden
            x     = matrix(:,1); %in mm
            y     = matrix(:,2);
            z     = matrix(:,3);
            pitch = (matrix(:,4)*360)/6.28; %rad in GRAD umgerechnet
            yaw   = (matrix(:,5)*360)/6.28;
            roll  = (matrix(:,6)*360)/6.28;
            %Berechne Different zwischen Maximun und Minimum der jeweiligen Bewegung
            x_diff = max(x)-min(x);
            y_diff = max(y)-min(y);
            z_diff = max(z)-min(z);
            pitch_diff = max(pitch) - min(pitch);
            yaw_diff   = max(yaw)   - min(yaw);
            roll_diff  = max(roll)  - min(roll);
            X_max = max(abs(x));
            Y_max = max(abs(y));
            Z_max = max(abs(z));
            Pitch_max = max(abs(pitch));
            Yaw_max = max(abs(yaw));
            Roll_max = max(abs(roll));
            ed=0;
            for i = 2:length(x)
                ed = ed + sqrt(((x(i)-x(i-1))^2 + (y(i)-y(i-1))^2) + (z(i)-z(i-1))^2);
            end %i
            
            %         ed_both_runs = [ed_both_runs ed];
            
            %%% auch vol2vol max berechnen?
            xi = x(1:end-1)-x(2:end);
            x_vol2vol=max(abs(xi));
            yi= y(1:end-1)-y(2:end);
            y_vol2vol=max(abs(yi));
            zi= z(1:end-1)-z(2:end);
            z_vol2vol=max(abs(zi));
            pitchi=pitch(1:end-1)-pitch(2:end)
            pitch_vol2vol=max(abs(pitchi));
            yawi= yaw(1:end-1)-yaw(2:end);
            yaw_vol2vol=max(abs(yawi));
            rolli= roll(1:end-1)-roll(2:end);
            roll_vol2vol=max(abs(rolli));
            
            figure;
            mu=[x y z];
            mi=[pitch yaw roll];
            subplot(211);
            plot(mu);
            legend('x','y','z','location', 'NorthEastoutside');
            xlabel('Volumes');
            ylabel('movement in mm');
            subplot(212);
            plot(mi);
            legend('pitch','yaw','roll','location','NorthEastoutside');
            xlabel('Volumes');
            ylabel('rotations in °');
            cd ([output_path, '\rgsubs']);
            name=[subjects{sub},'_realignment'];
            if ~exist([name,'.pdf'])
                saveas(gcf,name,'pdf');
            end
            close all;
            cd ..
            
            
            fprintf(fid, '%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t%6.2f\t', x_diff, y_diff, z_diff, pitch_diff, yaw_diff, roll_diff, ed, X_max, Y_max, Z_max, Pitch_max, Yaw_max, Roll_max, x_vol2vol, y_vol2vol, z_vol2vol, pitch_vol2vol, yaw_vol2vol, roll_vol2vol);
            data(sub).vp = [cell2mat(s)];
            data(sub).variables = [{'x_diff'}, 'y_diff', 'z_diff', 'pitch_diff', 'yaw_diff', 'roll_diff', 'ed', 'X_max', 'Y_max', 'Z_max', 'Pitch_max', 'Yaw_max', 'Roll_max', 'x_vol2vol', 'y_vol2vol', 'z_vol2vol', 'pitch_vol2vol', 'yaw_vol2vol', 'roll_vol2vol'];
            data(sub).rp = [x_diff, y_diff, z_diff, pitch_diff, yaw_diff, roll_diff, ed, X_max, Y_max, Z_max, Pitch_max, Yaw_max, Roll_max, x_vol2vol, y_vol2vol, z_vol2vol, pitch_vol2vol, yaw_vol2vol, roll_vol2vol];
                 end %run
            %fprintf(fid, '%6.2f\t', mean(ed_both_runs));
            fprintf(fid, '\n');
            %     else
            %         fprintf(subjects{sub}, 'has 2 runs')
            %         fprintf(fod, '%s\t', subjects{sub})
            %         fprintf(fid, '\n');
            %     end
            
            
            end
        end
        eval(['save ' savestr ' data']);
        fclose(fid);
        % fclose(fod)
        fprintf('RP Übersicht %s nach %s geschrieben\n', output_file, output_path)
        % fprintf('2runs VPs %s nach %s geschrieben\n', output_file, output_path)


