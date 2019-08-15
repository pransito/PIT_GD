function resStruct = jpa_getSubstruct(parentStruct, searchStruct)
% Funktion that searches the Substruct in a parentStruct and gives the
% substruct back. If nothing is found an empty cell will be given back.
%
% ############################## CAUTION: ##############################
% # This script works recursive! This could take a long time           #
% ######################################################################
%
% Syntax:
%    jpa_getSubstruct(parentStruct, searchStruct)
%
% Inputs:
%     parentStruct         - Parent-Structure
%     searchStruct         - Substruct-fieldname String
%
% Outputs:
%     resStruct            - first Substructure of Parent-Structure which
%                               was found for Search-Name in searchStruct
%
% Example:
%     jpa_getSubstruct(parentStruct, 'B')
%       where parentStruct:
%           pS.A.C = 1;
%           pS.B.D = 2;
%           pS.B.E = 3;
%       -> Output: B
%       where B:
%           B.D = 2;
%           B.E = 3;
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
% Sep 2015; Last revision: 13-Nov-2015

%------------- BEGIN CODE --------------

% get names of parentStruct
fields = fieldnames(parentStruct);
% check for emptyness
if ~isempty(fields)
    % loop throught all fields
    for i=1:1:length(fields)
        % check if current field is the one we search for
        if strcmp(fields{i,1},searchStruct) % case: yes
            % give search struct back
            resStruct = parentStruct.(fields{i,1});
            return;
        else % case: no
            % call the function recursive one level deeper if type is
            % struct.
            if isstruct(parentStruct.(fields{i,1}))
                resStruct = jpa_getSubstruct(parentStruct.(fields{i,1}),searchStruct);
                if ~isempty(resStruct)
                    return;
                end
            else
                resStruct = cell.empty;
            end
        end
    end
end
end

%------------- END CODE --------------