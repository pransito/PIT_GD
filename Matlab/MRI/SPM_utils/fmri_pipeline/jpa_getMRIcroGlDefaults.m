function mricro = jpa_getMRIcroGlDefaults()
% function that returns default configuration for MRIcroGL.ini-Script file.
% change values here to set default values.
%
% Syntax:  jpa_getMRIcroGlDefaults
%
% Outputs:
%     mricro - Substruct containing default values to MRIcroGL.ini-Script
% For a detailed Discription of possible Parameters for MRIcroGL StartScript
%           see Documentation under
%       http://www.mccauslandcenter.sc.edu/CRNL/sw/mricrogl/manual.pdf
%
% Example:
%    jpa_getMRIcroGlDefaults()
%
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_buildStartupScript_mricro

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 04-Sep-2015

%------------- BEGIN CODE --------------

% design your MRIcroGL Script
% build everything as Struct! save everything as String!
% If you wish not to use an option use '' or comment the line
% Do not use brackets in the String!
% also write numerical values as strings!
%
% ________________________________NECESSARY________________________________
% This is the necessary part. These lines have to be filled!
% background Image to load
mricro.loadimage{1} = '';
% .........................................................................
% Select layer(s) to overlay
% Define as many overlays as you want
mricro.overlayload{1} = '';
% mricro.overlayload{2} = 'path\to\mask.nii';
% mricro.overlayload{3} = 'path\to\mask.nii';
% .........................................................................
% _____________________________OPTIONAL____________________________________
% these lines are optional. You can define here everything that MRIcroGL
% accepts as StartupScript-order. Save everything as Array and everything
% as String! For detailed explanation see:
% http://www.mccauslandcenter.sc.edu/CRNL/sw/mricrogl/manual.pdf
%
% Uncomment or comment lines to not use them in StartupScript!
%
% trilinear (true) or nearest neighbor (false) Interpolation
mricro.overlayloadsmooth{1} = 'true';
% .........................................................................
% shader to use (you can only use these in folder 'shader' in MRIcroGL
% path)
mricro.shadername{1} = 'edge_phong';
% .........................................................................
% shwos the orientation Cube
mricro.framevisible{1} = 'false';
% .........................................................................
% cut through the 3Dimension-Image
% (depth of cut (Percentage), rotation of cut(degree), up-down camera(degree))
% for example '0.5, 90, 90'
% .........................................................................
%mricro.clipazimuthelevation{1} = '';
% .........................................................................
%mricro.shaderadjust{1} = 'colorTemp,0.0';
% .........................................................................
%mricro.contrastminmax{1} = '';
% .........................................................................
% backgroundcolor; RGB; 255,255,255 = white; 0,0,0 = black; 255,0,0 = red;
% 0,255,0 = green ; 0,0,255 = blue ;
mricro.backcolor{1} = '0,0,0';
% .........................................................................
% sets the color-scheme for background overlay
mricro.colorname{1} = 'Grayscale';
% .........................................................................
%mricro.maximumintensity{1} = 'false';
% .........................................................................
% color-Scheme to use (You can only select those in folder 'lut' in
%  MRIcroGL path)
mricro.overlaycolorname{1} = '1,1hot';
mricro.overlaycolorname{2} = ''; %'2,1hot'
mricro.overlaycolorname{3} = ''; %'3,1hot'
% .........................................................................
% transparency from overlay(s) to the background (Percentage)
mricro.overlaytransparencyonbackground{1} = '0';
% .........................................................................
% transparency from overlay(s) to others
mricro.overlaytransparencyonoverlay{1} = '0';
% .........................................................................
% colorbar coords (left, top , right, botton)
% use 0.93,0.1,0.95,0.9 for a small color bar on the right
% use 0.1,0.9,0.12,0.1 for the same color bar on the left
% use 0.1,0.92,0.9,0.9 for the same color bar on the top
% use 0.9,0.12,0.1,0.1 for the same color bar on the botton
mricro.colorbarcoord{1} = '0.9,0.12,0.1,0.1';
% .........................................................................
% Disable Colorbar if overlay sphere Image is used
mricro.colorbarvisible{1} = 'false';
% .........................................................................
% shows the contrast-Form
mricro.contrastformvisible{1} = '';
% .........................................................................
% get the Maximum Intensity-value for each overlay & set Color Intensity
mricro.overlayminmax{1} = '1,0,5';
%mricro.overlayminmax{2} = '2,0,5';
%mricro.overlayminmax{3} = '3,0,5';
% .........................................................................
% starting position for Rotation
mricro.azimuthelevation{1} = '90,0';
% .........................................................................
% set Rotation elevation
mricro.elevation{1} = '0';
% .........................................................................
% set Rotation azimuth
mricro.azimuth{1} = '0';
% .........................................................................
end
%------------- END OF CODE --------------