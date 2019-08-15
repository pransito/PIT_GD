% script to extract picture onset score
function [Y,all_subs] = agk_get_secondlevel_ROI_eigenvariates(path_scnd_level_SPM,path_ROI,con)

disp([path_scnd_level_SPM ': Trying to extract.'])

try
    load(path_scnd_level_SPM)
    
    % get the xSPM for extraction
    [SPMp, xSPMp] = agk_make_result_spm(path_scnd_level_SPM,con,1, 1,0); % contrast number has to be the right one!
    cd ..
    cur_SPM   = SPMp;
    cur_xSPM  = xSPMp;
    
    % get subject name
%     cur_con_mat = SPMp.xY.P;
%     all_subs    = {};
%     for kk = 1:length(cur_con_mat)
%         [f p e] = fileparts(cur_con_mat{kk});
%         startid = regexp(p,'VPPG.');
%         p       = p([startid:end]);
%         all_subs{kk,1} = p;
%     end
    
    cur_con_mat = SPMp.xY.P;
    all_subs    = {};
    for kk = 1:length(cur_con_mat)
        p = strsplit(cur_con_mat{kk},'\');
        all_subs{kk,1} = p{3};
    end
    
    % get a name
    [f,p,e] = fileparts(path_ROI);
    p       = strrep(p,' ','_');
    
    % get some info on mask
    xY.spec = spm_vol(path_ROI);
    
    % xY     - VOI structure
    % xY.xyz  = all_coord{ii}; % xY.xyz          - centre of VOI {mm}
    xY.Ic      = 0; % contrast used to adjust data (0 - no adjustment)
    xY.Sess    = 1; % session index
    xY.def     = 'mask';
    xY.xyz     = [0;0;0]; % sort of like a starting point to get to VOI (?)
    new_name_1 = ['extr_' p num2str(con)];
    xY.name    = new_name_1;
    disp('Extracting now!')
    [Y, xY]    = spm_regions(cur_xSPM,cur_SPM,[],[xY]);

catch MExc
    disp([cur_sub ': Something went wrong.']);
    Y = MExc;
    
end

end