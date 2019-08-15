function perm = jpa_build2Permutation(vector)
% Function that returns all Permutations of input-vector consisting of 
% two numbers. 
% So Output for Input-Vector [1 2 3] would be [1 2] [1 3] [2 3]
%
% Syntax:  
%    perm = jpa_build2Permutation(vector)
%
% Inputs:
%    vector  - vector containing digits
%
% Outputs:
%    perm    - all Permutations of vector  consisting of two numbers. 
%
% Example:
%           perm = jpa_build2Permutation([1 2 3])
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

% Index
ind = 1;
% size
[a b] = size(vector);
% check if Permutation is usless
if b > 1 
    % run through all cols
    for i=1:1:b-1
        % run through all elements
        for j =i+1:1:b
            % build permutation
            perm{ind} = [vector(i) vector(j)];
            % increase index
            ind = ind +1;
        end
    end
    
else
    % set perm to vector
    perm{1} = vector(1);
end
end
%------------- END CODE --------------