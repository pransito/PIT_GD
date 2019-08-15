function twu_make_pub_table(what)

[f,p] = uigetfile({'*.xls; *.xlsx'},'Bitte Anatomy toolbox output wählen');
[d,t] = xlsread(fullfile(p,f));
d = [NaN(abs(size(d,1)-size(t,1)),size(d,2)); d];
if size(d,2) < 11
    d = [NaN(size(d,1),abs(size(d,2)-11)) d];
end
[dummy,results_name,dummy] = fileparts(f);

% structure template
s = struct('cluster_size',{},...
           'x_tal', {}, 'y_tal', {}, 'z_tal', {},...
           'x_mni', {}, 'y_mni', {}, 'z_mni', {},...
           't', {},'z',{},...
           'p_uncorr',{},...
           'p_FDR',{},...
           'p_FWE',{},...
           'hemisphere',{},...
           'brain_structure',{},...
           'cyto_architectonical_structure',{},...
           'cyto_architectonical_probability',{});           
       
if what(1)
    % working on anatomy output file
    cluster_start = [];
    for i = 1:size(t,1)
        if strcmp(strtok(t(i,1)),'Cluster')
            cluster_start = [cluster_start;  i];
        end
    end

    cluster = cell(1,numel(cluster_start));

    for i = 1:numel(cluster_start)
        c = struct(s);
        number_maxima = 1;
        if i < numel(cluster_start)
            last = cluster_start(i+1)-1;
        else
            last = size(d,1);
        end
        for j = cluster_start(i):last
            [start , rest] = strtok(t(j,1));
            if strcmp(start,'Cluster')
               [start , rest] = strtok(rest);
               [start , rest] = strtok(rest);
               cs = char(start);
            end

            if strcmp(start,'Maximum')
                [start , rest] = strtok(t(j,2));
                c(number_maxima).cluster_size = str2num(cs(2:end));
                c(number_maxima).t = str2num(char(rest));
                c(number_maxima).x_tal = d(j,4);
                c(number_maxima).y_tal = d(j,5);
                c(number_maxima).z_tal = d(j,6);
                c(number_maxima).x_mni = d(j,9);
                c(number_maxima).y_mni = d(j,10);
                c(number_maxima).z_mni = d(j,11);
                if c(number_maxima).x_tal < 0 && c(number_maxima).x_mni < 0 
                    c(number_maxima).hemisphere = 'L';
                else
                    c(number_maxima).hemisphere = 'R';
                end
                [start , rest] = strtok(t(j,13));
                if ~strcmp(char(start),'N/A')
                    rest = char(rest);
                    c(number_maxima).brain_structure = rest(2:end);
                else
                    c(number_maxima).brain_structure = char(start);
                end
                if j+1 <= size(t,1)
                    [start , rest] = strtok(t(j+1,2));
                    if strcmp(start,'Probability')
                        c(number_maxima).cyto_architectonical_structure = char(t(j+1,3));
                        c(number_maxima).cyto_architectonical_probability = d(j+1,4);
                    end
                end
                number_maxima = number_maxima + 1;
            end
        end
        cluster(i) = {c};
    end
end

if what(2)
    [f,p] = uigetfile('*.mat','Bitte SPM Tabellenstruktur wählen');
    load(fullfile(p,f));
    % working on SPM output structure
    for i = 1:numel(cluster_start)
        for j = 1:size(TabDat.dat,1)
            spm_coord = round(cell2mat(TabDat.dat(j,12)));
            for k = 1:numel(cluster{i})
                if  spm_coord(1)== cluster{i}(k).x_mni && spm_coord(2)== cluster{i}(k).y_mni &&spm_coord(3)== cluster{i}(k).z_mni
                    cluster{i}(k).z = cell2mat(TabDat.dat(j,10));
                    cluster{i}(k).t = cell2mat(TabDat.dat(j,9));
                    cluster{i}(k).p_uncorr = cell2mat(TabDat.dat(j,11));
                    cluster{i}(k).p_FDR = cell2mat(TabDat.dat(j,8));
                    cluster{i}(k).p_FWE = cell2mat(TabDat.dat(j,7));
                end
            end
        end
    end
end

% print results to file
hdr = cell(1,11);
hdr{1} = 'Brain structure (CP %)';
hdr{2} = 'CP(%)';
hdr{3} = 'H';
hdr{4} = 'MNI coord. (mm)';
hdr{5} = 'x';
hdr{6} = 'y';
hdr{7} = 'z';
hdr{8} = 'Z (peak)';
hdr{9} = 'T (peak)';
hdr{10} = 'p (uncorr.)';
hdr{11} = 'p (FDR)';
hdr{12} = 'p (FWE)';
hdr{13} = 'Cluster size (vox)';


fid = fopen(strcat('Pub_table_',results_name,'.txt'),'w');
fprintf(fid,'%s\t', char(hdr{1}),char(hdr{3}),char(hdr{13}),char(hdr{8}),char(hdr{9}),char(hdr{10}),char(hdr{11}),char(hdr{12}),' ',char(hdr{4}));
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\t',' ',' ',' ',' ',' ',' ',' ',' ',char(hdr{5}),char(hdr{6}),char(hdr{7}));
fprintf(fid,'%s\n',' ');
fprintf(fid,'%s\n',' ');
for i=1:numel(cluster)
    for j=1:numel(cluster{i})
        fprintf(fid,'%s\t',char(cluster{i}(j).brain_structure),char(cluster{i}(j).hemisphere));
        if j == 1
            fprintf(fid,'%10.0f\t',cluster{i}(j).cluster_size);
        else
            fprintf(fid,'%s\t',' ');
        end 
        fprintf(fid,'%3.2f\t',cluster{i}(j).z);
        fprintf(fid,'%3.2f\t',cluster{i}(j).t);
        if cluster{i}(j).p_uncorr < 0.001
            fprintf(fid,'%s\t','<.001');
        else
            fprintf(fid,'%0.3f\t',cluster{i}(j).p_uncorr);
        end
        fprintf(fid,'%0.3f\t',cluster{i}(j).p_FDR,cluster{i}(j).p_FWE);
        fprintf(fid,'%3.0d\t',cluster{i}(j).x_mni,cluster{i}(j).y_mni,cluster{i}(j).z_mni);
        fprintf(fid,'%s\n',' ');
        if ~isempty(cluster{i}(j).cyto_architectonical_structure)
            fprintf(fid,'%s',char(cluster{i}(j).cyto_architectonical_structure),' (');
            fprintf(fid,'%3.0d',cluster{i}(j).cyto_architectonical_probability);
            fprintf(fid,'%s\n',' %)');
        end
    end
    fprintf(fid,'%s\n',' ');
end
fclose(fid);
