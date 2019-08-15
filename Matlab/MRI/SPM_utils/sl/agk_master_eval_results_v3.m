%% function to evaluate sd_level con maps
% if ROIs are given then they are used for SVC
% if not, then no SVC is performed
% pSPM: paths to all the SPMs
% ROI is one path to a ROI
% no try catch anymore

function all_sig_results = agk_master_eval_results_v3(pSPM,ROI,reference,cur_atlas,thr_p,thr_k)

disp(['NOW RUNNING... ' ROI])
cur_ROI = ROI;
for ii = 1:length(pSPM)
    % go through all SPM.mat
    disp(['NOW RUNNING... ' pSPM{ii}])
    cur_path = pSPM{ii};
    cur_cons_string = cur_path;
    
    % get the name of current SPM.mat
    tmp = textscan(fileparts(pSPM{ii}),'%s','delimiter','\\');
    cur_SPMname =[];
    for kk = (length(tmp{1})-5):length(tmp{1})
        if kk == length(tmp{1})
            cur_SPMname = [cur_SPMname tmp{1}{kk}];
        else
            cur_SPMname = [cur_SPMname tmp{1}{kk} '_'];
        end
    end
    
    % go through all contrasts
    
    % loading SPM mat
    load(pSPM{ii})
    disp(['Loading...' pSPM{ii}])
    
    % are there cons?
    cur_numcon = length(SPM.xCon);
    
    
    % get the names of the cons
    cur_cons = {};
    for kk = 1:cur_numcon
        cur_cons{kk} =SPM.xCon(1,kk).name;
    end
    TabDat.coninfo{ii,1} = cur_cons;
    TabDat.SPMname{ii,1} = cur_SPMname;
    
    for kk = 1:cur_numcon
        disp (['cur con is...', cur_cons{kk}, ' selected ROI: ' cur_ROI])
        TabDat.results{ii,kk} = agk_get_SVC(cur_ROI,reference,pSPM{ii},kk,thr_p,thr_k,0);
        disp(['get SVC was succesful using ROI: ' cur_ROI])
    end
end

disp(TabDat)

%% now check for sig. results
which_spm(12,'genaucka',1)
xA=spm_atlas('load',cur_atlas);
all_sig_results = [];
sig_ct = 0;
if isfield(TabDat,'results')
    % all SPMs
    for ii = 1:size(TabDat.results,1)
        % all contrasts
        for jj = 1:size(TabDat.results,2)
            cur_TabDat = TabDat.results{ii,jj};
            if isempty(cur_TabDat)
                continue
            end
            
            % get the peaks/cluster p below 0.05FWE peak
            % peak-wise
            all_peak_p        = cell2mat_nan(cur_TabDat.dat(:,7));
            peak_coord_of_sig = cur_TabDat.dat(:,end);
            peak_coord_of_sig = peak_coord_of_sig(all_peak_p <= 0.05);
            peak_pfwe_values  = all_peak_p(all_peak_p <= 0.05);
            
            % cluster-wise
            all_clus_p        = cell2mat_nan(cur_TabDat.dat(:,3));
            k_n_of_sig_clus   = cur_TabDat.dat(:,5);
            k_n_of_sig_clus   = k_n_of_sig_clus(all_clus_p <= 0.05);
            clus_pfwe_values  = all_clus_p(all_clus_p <= 0.05);
            clus_coord_of_sig = cur_TabDat.dat(:,end);
            clus_coord_of_sig = clus_coord_of_sig(all_clus_p <= 0.05);
            
            if ~isempty(peak_coord_of_sig) || ~isempty(k_n_of_sig_clus)
                %if ~isempty(k_n_of_sig_clus) % only cluster level counts
                sig_ct = sig_ct+1;
                % sig_labels
                sig_labels = {};
                for kk = 1:length(peak_coord_of_sig)
                    sig_labels{kk,1} = spm_atlas('query',xA,peak_coord_of_sig{kk});
                end
                
                % cluster label
                sig_labels_clus = {};
                for kk = 1:length(clus_coord_of_sig)
                    sig_labels_clus{kk,1} = spm_atlas('query',xA,clus_coord_of_sig{kk});
                end
                
                all_sig_results(sig_ct,1).name       = TabDat.SPMname{ii};
                all_sig_results(sig_ct,1).con        = TabDat.coninfo{ii}{jj};
                all_sig_results(sig_ct,1).peak_coord = peak_coord_of_sig;
                all_sig_results(sig_ct,1).labels     = sig_labels;
                all_sig_results(sig_ct,1).peakfw     = peak_pfwe_values;
                all_sig_results(sig_ct,1).clusfw     = clus_pfwe_values;
                all_sig_results(sig_ct,1).k_clus     = k_n_of_sig_clus;
                all_sig_results(sig_ct,1).labels_clus= sig_labels_clus;
            end
        end
    end
    
else
    disp('NO SIG RESULTS AT ALL')
    all_sig_results = 'NO SIG RESULTS AT ALL';
end

% save the results

end