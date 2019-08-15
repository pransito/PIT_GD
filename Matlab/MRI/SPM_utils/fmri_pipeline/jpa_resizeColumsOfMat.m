function [mat status] = jpa_resizeColumsOfMat(mat,colIndex)
% Function that fills every row of a input nxn-Matrix with zeros up to
% an colum index given in second argument or removes Colums of input Marix
% up to Index given in colIndex
%
% Syntax:  [mat status] = jpa_resizeColumsOfMat(mat, colIndex)
%
% Inputs:
%    mat        - nxn-Matrix
%    colIndex   - limit-Index to where to fill or remove cols of Matrix
%
% Outputs:
%    mat        - Matrix with zeros from orginally matrix to colIndex in
%                   every row or removed elements from colIndex to
%                   orginally matrix
%
% Example:
%    [mat status] = jpa_resizeColumsOfMat([1 2 3] , 5)
%       -> output: [1 2 3 0 0], 1
%    [mat status] = jpa_resizeColumsOfMat([1 2 3 4 5] , 3)
%       -> output: [1 2 3], -1
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also:

% Author: Jan Albrecht
% Work address: alexander.genauck@charite.de
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 29-Sep-2015

%------------- BEGIN CODE --------------

% check for input Arguments
if nargin ~= 2
    error('Wrong input-Arguments!');
end
% get size of weight
[a,b] = size(mat);
if b < colIndex % matrix is to small -> addZeros
    % Fill weight with zeros up to length
    mat(:,end+1:colIndex) = 0;
    status = 1;
elseif b > colIndex  % matrix is to big -> remove Elements
    mat(:,colIndex+1:end) = [];
    status = -1;
else
    status = 0;
end
end
%------------- END CODE --------------