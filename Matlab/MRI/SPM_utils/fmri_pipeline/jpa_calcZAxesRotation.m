function rotateDegree = jpa_calcZAxesRotation(coord)
% Function that calculates y-axis-rotation from 3D Coord 0/0/0
% to given coords
%
% Syntax:  
%    rotateDegree = jpa_calcZAxesRotation(coord)
%
% Inputs:
%    coord          - Coords where to turn z-Axis to
%
% Outputs:
%    rotateDegree   - Degree
%                    
% Example:
%     rotateDegree = jpa_calcZAxesRotation([-20 10 50])
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

% calculate z-axis-rotation absolute
if coord(1,2) == 0
    value2 = 0;
else
    value2 = coord(1,1)/coord(1,2);
end
% determine wich direction to turn
if sign(coord(1,1)) < 0 && sign(coord(1,2)) < 0     % both negative
    rotateDegree = round(-1 *(180 - atand(value2)) + 90);
else if sign(coord(1,1)) < 0                            % first negative
        rotateDegree = round((-atand(value2)) + 90);
    else if sign(coord(1,2)) < 0                        % secound negative
            rotateDegree = round((180 - atand(value2)) + 90);
        else                                                % both positive
            rotateDegree = round((atand(value2)) + 90);
        end
    end
end
%------------- END CODE --------------