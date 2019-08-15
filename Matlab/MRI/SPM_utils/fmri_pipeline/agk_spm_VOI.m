function [TabDat, xSVC] = agk_spm_VOI(SPM,xSPM,CustomParams)
% List of local maxima and adjusted p-values for a small Volume of Interest
% FORMAT [TabDat,xSVC] = spm_VOI(SPM,xSPM,hReg,[xY])
%
% SPM    - Structure containing analysis details (see spm_spm)
%
% xSPM   - Structure containing SPM, distribution & filtering details
%          Required fields are:
% .swd     - SPM working directory - directory containing current SPM.mat
% .Z       - minimum of n Statistics {filtered on u and k}
% .n       - number of conjoint tests
% .STAT    - distribution {Z, T, X or F}
% .df      - degrees of freedom [df{interest}, df{residual}]
% .u       - height threshold
% .k       - extent threshold {resels}
% .XYZ     - location of voxels {voxel coords}
% .XYZmm   - location of voxels {mm}
% .S       - search Volume {voxels}
% .R       - search Volume {resels}
% .FWHM    - smoothness {voxels}
% .M       - voxels -> mm matrix
% .VOX     - voxel dimensions {mm}
% .DIM     - image dimensions {voxels} - column vector
% .Vspm    - mapped statistic image(s)
% .Ps      - uncorrected P values in searched volume (for voxel FDR)
% .Pp      - uncorrected P values of peaks (for peak FDR)
% .Pc      - uncorrected P values of cluster extents (for cluster FDR)
% .uc      - 0.05 critical thresholds for FWEp, FDRp, FWEc, FDRc
%
% hReg   - Handle of results section XYZ registry (see spm_results_ui.m)
% xY     - VOI structure
%
% TabDat - Structure containing table data (see spm_list.m)
% xSVC   - Thresholded xSPM data (see spm_getSPM.m)
%__________________________________________________________________________
%
% spm_VOI is  called by the SPM results section and takes variables in
% SPM to compute p-values corrected for a specified volume of interest.
%
% The volume of interest may be defined as a box or sphere centred on
% the current voxel or by a mask image.
%
% If the VOI is defined by a mask this mask must have been defined
% independently of the SPM (e.g. using a mask based on an orthogonal
% contrast).
%
% External mask images should be in the same orientation as the SPM
% (i.e. as the input used in stats estimation). The VOI is defined by
% voxels with values greater than 0.
%
% See also: spm_list
%__________________________________________________________________________
% Copyright (C) 1999-2014 Wellcome Trust Centre for Neuroimaging

% Karl Friston
% $Id: spm_VOI.m 6080 2014-07-01 16:00:22Z guillaume $


%-Parse arguments
%--------------------------------------------------------------------------
if nargin < 2, error('Not enough input arguments.'); end
if nargin < 3, hReg = []; end
if nargin < 4, xY = []; end

Num = spm_get_defaults('stats.results.svc.nbmax');   % maxima per cluster
Dis = spm_get_defaults('stats.results.svc.distmin'); % distance among maxima {mm}

if ~isfield(CustomParams,'Num'), CustomParams.Num = Num; end
if ~isfield(CustomParams,'Dis'), CustomParams.Dis = Dis; end

%-Title
%--------------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Small Volume Correction']);

%-Get current location {mm}
%--------------------------------------------------------------------------
% try
%     xyzmm  = xY.xyz;
% catch
%     xyzmm  = spm_results_ui('GetCoords');
% end

if ~isfield(CustomParams,'xyzmm')
	CustomParams.xyzmm = spm_results_ui('GetCoords');
else
	CustomParams.xyzmm = reshape(CustomParams.xyzmm,3,1); % Ensure row vector
    xyzmm = CustomParams.xyzmm;
end
    
%-Specify search volume
%--------------------------------------------------------------------------
% if isfield(xY,'def')
%     switch xY.def
%         case 'sphere'
%             SPACE = 'S';
%         case 'box'
%             SPACE = 'B';
%         case 'mask'
%             SPACE = 'I';
%         otherwise
%             error('Unknown VOI type.');
%     end
% else
%     str    = sprintf(' at [%.0f,%.0f,%.0f]',xyzmm(1),xyzmm(2),xyzmm(3));
%     SPACE  = spm_input('Search volume...',-1,'m',...
%              {['Sphere',str],['Box',str],'Image'},['S','B','I']);
% end

if ~isfield(CustomParams,'SPACE')
	CustomParams.SPACE = spm_input('Search volume...',-1,'m',...
		{['Sphere',str],['Box',str],'Image'},['S','B','I']);
end

%-Voxels in entire search volume {mm}
%--------------------------------------------------------------------------
XYZmm      = SPM.xVol.M(1:3,:)*[SPM.xVol.XYZ; ones(1, SPM.xVol.S)];
Q          = ones(1,size(xSPM.XYZmm,2));
O          = ones(1,size(     XYZmm,2));
FWHM       = xSPM.FWHM;

switch CustomParams.SPACE

	case 'S' %-Sphere
	%---------------------------------------------------------------
	if ~isfield(CustomParams,'D')
		CustomParams.D          = spm_input('radius of VOI {mm}',-2);
	end

	str        = sprintf('%0.1fmm sphere',CustomParams.D);
	j          = find(sum((xSPM.XYZmm - CustomParams.xyzmm*Q).^2) <= CustomParams.D^2);
	k          = find(sum((     XYZmm - CustomParams.xyzmm*O).^2) <= CustomParams.D^2);
	CustomParams.D          = CustomParams.D./xSPM.VOX;


	case 'B' %-Box
	%---------------------------------------------------------------
	if ~isfield(CustomParams,'D')
		CustomParams.D          = spm_input('box dimensions [k l m] {mm}',-2);
	end

    if length(CustomParams.D)~=3, CustomParams.D = ones(1,3)*CustomParams.D(1); end
	str        = sprintf('%0.1f x %0.1f x %0.1f mm box',CustomParams.D(1),CustomParams.D(2),CustomParams.D(3));
	j          = find(all(abs(xSPM.XYZmm - CustomParams.xyzmm*Q) <= CustomParams.D(:)*Q/2));
	k          = find(all(abs(     XYZmm - CustomParams.xyzmm*O) <= CustomParams.D(:)*O/2));
	CustomParams.D          = CustomParams.D./xSPM.VOX;


	case 'I' %-Mask Image
	%---------------------------------------------------------------
	if ~isfield(CustomParams,'D')
		Msk   = spm_select(1,'image','Image defining search volume');
        CustomParams.D     = spm_vol(Msk);
    else
        Msk            = CustomParams.D;
        CustomParams.D = spm_vol(Msk);
	end

	str   = sprintf('image mask: %s',spm_str_manip(Msk,'a30'));
    
    % fix up string so tex interpreter works correctly
    str   = strrep(str,'\','\\');
    str   = strrep(str,'_','\_');
    str   = strrep(str,'^','\^');
    str   = strrep(str,'{','\{');
    str   = strrep(str,'}','\}');
    
	VOX   = sqrt(sum(CustomParams.D.mat(1:3,1:3).^2));
	FWHM  = FWHM.*(xSPM.VOX./VOX);
	XYZ   = CustomParams.D.mat \ [xSPM.XYZmm; ones(1, size(xSPM.XYZmm, 2))];
	j     = find(spm_sample_vol(CustomParams.D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);
	XYZ   = CustomParams.D.mat \ [     XYZmm; ones(1, size(    XYZmm, 2))];
	k     = find(spm_sample_vol(CustomParams.D, XYZ(1,:), XYZ(2,:), XYZ(3,:),0) > 0);

end

xSPM.S     = length(k);
xSPM.R     = spm_resels(FWHM,CustomParams.D,CustomParams.SPACE);
xSPM.Z     = xSPM.Z(j);
xSPM.XYZ   = xSPM.XYZ(:,j);
xSPM.XYZmm = xSPM.XYZmm(:,j);

%-Restrict FDR to the search volume
%--------------------------------------------------------------------------
df         = xSPM.df;
STAT       = xSPM.STAT;
DIM        = xSPM.DIM;
R          = xSPM.R;
n          = xSPM.n;
Vspm       = xSPM.Vspm;
u          = xSPM.u;
S          = xSPM.S;

try, xSPM.Ps = xSPM.Ps(k); end
if STAT ~= 'P'
    [up, xSPM.Pp]     = spm_uc_peakFDR(0.05,df,STAT,R,n,Vspm,k,u);
    uu                = spm_uc(0.05,df,STAT,R,n,S);
end
try % if STAT == 'T'
    V2R               = 1/prod(xSPM.FWHM(DIM>1));
    [uc, xSPM.Pc, ue] = spm_uc_clusterFDR(0.05,df,STAT,R,n,Vspm,k,V2R,u);
catch
    uc                = NaN;
    ue                = NaN;
    xSPM.Pc           = [];
end
try, xSPM.uc          = [uu up ue uc]; end

%-Tabulate p values
%--------------------------------------------------------------------------
str        = sprintf('search volume: %s',str);
if any(strcmp(CustomParams.SPACE,{'S','B'}))
    str = sprintf('%s at [%.0f,%.0f,%.0f]',str,xyzmm(1),xyzmm(2),xyzmm(3));
end

%TabDat     = spm_list('List',xSPM,hReg,Num,Dis,str);
TabDat     = agk_spm_list('List',xSPM,[],Num,Dis,str);

if nargout > 1, xSVC = xSPM; end

%xSVC = xSPM;

%-Reset title
%--------------------------------------------------------------------------
spm('FigName',['SPM{',xSPM.STAT,'}: Results']);
