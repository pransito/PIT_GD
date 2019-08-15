function ret = jpa_getCovVec(mat)
% Function that combines all colums of a mxm cell-Matrix of each row.
% So output Matrix will be a mx1 Matrix.
%
% Syntax:
%    jpa_getCovVec(mat)
%
% Inputs:
%     mat               - mxm Matrix containing Cells
%
% Outputs:
%     ret               - mx1 Matrix containing Cells
%
% Example:
%     jpa_getCovVec({[1;2;3] [4;5;6] ; [7;8;9] [10;11;12]})
%       -> output: {[1;2;3;4;5;6];[7;8;9;10;11;12]}
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
% Sep 2015; Last revision: 13-Okt-2015

%------------- BEGIN CODE --------------

% get size
[a, b] = size(mat);

% initialize
ret = cell(a,1);

% loop through all rows
for i=1:1:a
    % loop through all cols
    sumInd = 1;
    for j=1:1:b
        % get length of cell
        len = length(mat{i,j});
        row(sumInd:sumInd+len-1,1) = mat{i,j};
        sumInd = sumInd + len;
    end
    ret{i} = row;
    clearvars row;
end
end
%------------- END CODE --------------