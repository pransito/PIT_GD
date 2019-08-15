function initials = jpa_getInitialienOfSting(str)
% Function returnes the first 3 Characters of each Cell-String in one
% concatenated string alphabetically ordered for each Column!
% The first letter of each Cell String will be capital
% the rest will be lowercase.
%
% Syntax:
%    initials = jpa_getInitialienOfSting(str)
%
% Inputs:
%    str    - Cell which contains a various number of letters
%
% Outputs:
%    init    - String which only contains the first 3 letters of every string
%               in str concatenated to a large String
%
% Example:
%    initials = jpa_depthSearch({'String1', 'eXAm2' , 'test3'})
%       -> Output: {StrExaTes}
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
% Sep 2015; Last revision: 14-Sep-2015

%------------- BEGIN CODE --------------

[a, b] = size(str);
% Initialisation
initField = repmat({''},a,b);
initials = repmat({''},1,b);
% Loops through rows and cols
for j=1:1:b
    for i=1:1:a
        % check whether Char or not
        if ischar(str{i,j})
            % check for empty strings
            if ~strcmp(str{i,j} , '')
                % check for length
                if length(str{i,j}) > 3
                    % Upper first letter, lower rest letters, save in init
                    initField{i,j} = strcat(upper(str{i,j}(1)), lower(str{i,j}(2:3)) );
                else
                    if length(str{i,j}) > 1
                        % Upper first letter, lower rest letters, save in init
                        initField{i,j} =  strcat(upper(str{i,j}(1)), lower(str{i,j}(2:length(str{i,j}))) );
                    else
                        % Upper first letter, save in init
                        initField{i,j} = upper(str{i,j}(1));
                    end
                end
            end
        else % case: not a char
            error('Input contains non-Char Elements!')
        end
    end
end
% order them and write them in one String for each Col!
for i=1:1:b
    initField(:,i) =  sort(initField(:,i));
end
for j=1:1:a
    for i=1:1:b
        initials{i} = strcat(initials{i},initField{j,i});
    end
end
end
%------------- END CODE --------------