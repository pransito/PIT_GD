function new_all_sig_results = jpa_getAllResults(pathToAllSigRes,current_sig_results)
% Function that combines a existing Results-File with a new Results-file.
% Results that already exists in old Results-File will be overwritten.
% Results that does exist in old Results-File and not in current_sig_results
% will not be deleted and will be written in output. So no Information will
% be lost.
%
% Syntax:
%    new_all_sig_results =
%    jpa_getAllResults(pathToAllSigRes,current_sig_results)
%
% Inputs:
%    pathToAllSigRes     - Path to old sig_results file
%    current_sig_results - Struct which contains new results
%     .type         - Name of statistical Analysis
%     .name         - Name of statistical Test-directory
%     .con          - Name of Contrast
%     .ClusterFWE   - Struct containing thresholded results of Cluster
%                       Familywise-error-correction
%     .ClusterFDR   - Struct containing thresholded results of Cluster
%                       False Detection Rate
%     .PeakFWE      - Struct containing thresholded results of PeakCoord
%                       Familywise-error-correction
%     .PeakFDR      - Struct containing thresholded results of PeakCoord
%                       False Detection Rate
%
% Outputs:
%    new_all_sig_results - Struct containing Information from old file
%       which are not in current_sig_results and all Information in
%       current_sig_results
%
% Example:
%    jpa_getAllResults('C:\all_sig_res.mat',current_sig_results)
%       where current_sig_results
%       .type         = 'ttest'
%       .name         = 'ttest'
%       .con          = 'con_0001'
%       .ClusterFWE   = []
%       .ClusterFDR   = []
%       .PeakFWE      = []
%       .PeakFDR      = []
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

% test for existance of all_sig_results.mat
if exist(pathToAllSigRes,'file')
    % load file
    all_sig_results = load(pathToAllSigRes);
    % get name of loaded file
    fieldname = fieldnames(all_sig_results);
    all_sig_results = all_sig_results.(fieldname{1,1});
    % check if all_sig_res is empty
    if ~isempty(all_sig_results)
        % check if current_sig_results is empty
        if ~isempty(current_sig_results)
            % dermine size of loaded .mat
            [l,b] = size(all_sig_results);
            % determine size of current_sig_results
            [l,d] = size(current_sig_results);
        else % case empty:
            % new_all_sig_results has to be all_sig_results because 
            % current_sig_results is empty
            new_all_sig_results = all_sig_results;
            return;
        end
    else % case empty:
        % new_all_sig_results has to be current_sig_results because
        % all_sig_results is empty
        new_all_sig_results = current_sig_results;
        return;
    end
    % Initialize index for new output
    inx = 0;
    % initialize logical vector(s)
    currResFound = false(d,1);
    found = false;
    % loop through all_sig_results rows
    for i=1:1:b
        % loop through current results rows
        for j=1:1:d
            % compare name and contrast-Name of all_sig_results and
            % current_sig_results
            if strcmp(all_sig_results(i).name , current_sig_results(j).name) ...
                    && strcmp(all_sig_results(i).con , current_sig_results(j).con)
                % case: both equal
                % in output will be written the new results in
                % current_sig_results
                inx = inx + 1;
                new_all_sig_results(inx) = current_sig_results(j);
                % set logical vector at position to true;
                currResFound(j,1) = true;
                % set found to true so the (old) name and contrast in
                % all_sig_results will not be written
                found = true;
                break;
            end
        end
        % check if test with contrast was found in current_sig_results
        if ~found
            % case:  not
            % write old results in new results because it has not been
            % renewed e.g. is not in current_sig_results
            inx = inx + 1;
            new_all_sig_results(inx) = all_sig_results(i);
        end
        % initialize logical for next result
        found = false;
    end
    % write rest of current_sig_results in output
    current_sig_results = current_sig_results(~currResFound);
    [l,c] = size(current_sig_results);
    for i=1:1:c
        inx = inx + 1;
        new_all_sig_results(inx) = current_sig_results(i);
    end
else % case: no old result file exists
    new_all_sig_results = current_sig_results;
end
end
%------------- END CODE --------------