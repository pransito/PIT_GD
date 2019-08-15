function rotateDegree = jpa_calcYAxesRotation(coord)
% Function that calculates y-axis-rotation from 3D Coord 0/0/0
% to given coords
%
% Syntax:  
%    rotateDegree = jpa_calcYAxesRotation(coord)
%
% Inputs:
%    coord          - Coords where to turn y-Axis to
%
% Outputs:
%    rotateDegree   - Degree
%                    
% Example:
%     rotateDegree = jpa_calcYAxesRotation([-20 10 50])
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

% calculate
if coord(1,2) == 0
    value1 = 0;
else
    value1 = coord(1,3)/coord(1,2);
end
if sign(coord(1,1)) < 0 && sign(coord(1,3)) < 0     % both negative
    rotateDegree = abs(round(atand(value1)));
else if sign(coord(1,1)) < 0                            % first negative
        rotateDegree = -1 * abs(round(atand(value1)));
    else if sign(coord(1,3)) < 0                    % third negative
            rotateDegree = abs(round(atand(value1)));
        else                                            % both positive
            rotateDegree = -1 * abs(round(atand(value1)));
        end
    end
end
end
%------------- END CODE --------------