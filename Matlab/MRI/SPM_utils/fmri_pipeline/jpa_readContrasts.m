function gppiContrasts = jpa_readContrasts(spmStruct, minEvents)
% Funktion that extracts contrasts out of an given spmStruct and builds new
% contrasts in a specified format for PPPI analysis.
%
% Syntax:
%    jpa_readContrasts(spmStruct, minEvents)
%
% Inputs:
%     spmStruct    - Struct from SPM (for more information see
%                       http://www.fil.ion.ucl.ac.uk/spm/doc/manual.pdf)
%     minEvents    - must be specified and must be 1 or greater,
%                       this tells the program how many events you need to 
%                       form a contrast. If there are fewer events, the 
%                       contrast is not created.
%
% Outputs:
%     gppiContrasts   - contrasts defined in a specified format needed for
%                       PPPI analysis
%
% Example:
%     jpa_readContrasts(SPM, 5)
%
% Other m-files required: none
% Subfunctions: none
% MAT-files required: none
%
% See also: jpa_gppp_loop jpa_getGppiContrasts

% Author: Jan Albrecht
% Work address:
% email: jan-philipp.albrecht@charite.de, j.p.albrecht@fu-berlin.de
% Website:
% Sep 2015; Last revision: 31-Okt-2017

%------------- BEGIN CODE --------------

% check input
if isfield(spmStruct,'Sess')
   sess = spmStruct.Sess;
   if  isfield(sess,'U')
      U = sess.U;
       if  ~isfield(U,'P') || ~isfield(U,'ons')
           error('Wrong SPM.mat structure!');
       end
   else
      error('Wrong SPM.mat structure!'); 
   end
else
    error('Wrong SPM.mat structure!');
end
% CHANGED BY ALEX
cur_size = size(spmStruct.Sess);
ySessLen = cur_size(1);
xSessLen = cur_size(2);
cur_size = size(spmStruct.Sess(1).U);
yULen    = cur_size(1);
xULen    = cur_size(2);
% CHANGED ALEX
% initiate counter
conIt = 1;
gppiContrasts = struct();
% loop over sessions
for sessIt=1:1:1 %xSessLen
   % loop over Predictors (U) - e.g. TASKS
   for preIt=1:1:xULen
       ui = spmStruct.Sess(sessIt).U(1,preIt);
       % get the amount of MainEffects
       [~, numMain] = size(ui.ons);
       % get the amount of parametric modulators
       [~, numPara] = size(ui.P);
       % produce contrast: each MainEffect with all parametric modulators
       for mainIt=1:1:numMain
           mainName = ui.name{1,mainIt};
           % add contrast (of onset regressor, without param mods)
           gppiContrasts(conIt).name = mainName;
           gppiContrasts(conIt).left = {mainName}; %left is always bigger than right
           gppiContrasts(conIt).right = {''};
           gppiContrasts(conIt).Weighted = 0;
           gppiContrasts(conIt).Contrail = [];
           gppiContrasts(conIt).STAT = 'T';
           gppiContrasts(conIt).MinEvents = minEvents;
           gppiContrasts(conIt).MinEventsPer = [];
           gppiContrasts(conIt).c = [];
           gppiContrasts(conIt).Prefix = [];
           conIt = conIt + 1;
           
           % loop over parametric modulators
           for paraIt=1:1:numPara
               pi = ui.P(1,paraIt);
               if pi.h >0 % else its 'none'
                   % add contrast 
                   gppiContrasts(conIt).name = [mainName 'x' pi.name];
                   gppiContrasts(conIt).left = {mainName}; %left is always bigger than right
                   gppiContrasts(conIt).right = {''};
                   gppiContrasts(conIt).Weighted = 0;
                   gppiContrasts(conIt).Contrail.L = {['x' pi.name '^' num2str(pi.h) ]};
                   gppiContrasts(conIt).STAT = 'T';
                   gppiContrasts(conIt).MinEvents = minEvents;
                   gppiContrasts(conIt).MinEventsPer = [];
                   gppiContrasts(conIt).c = [];
                   gppiContrasts(conIt).Prefix = [];
                   conIt = conIt + 1;
                                      % ALEX CHANGED: NOT NEEDED IS REDUNDANT BEGIN
%                    % add same contrast negative
%                    gppiContrasts(conIt).name = [mainName '_' pi.name '_neg'];
%                    gppiContrasts(conIt).left = {mainName}; %left is always bigger than right
%                    gppiContrasts(conIt).right = {''};
%                    gppiContrasts(conIt).Weighted = 0;
%                    gppiContrasts(conIt).Contrail.R = {['x' pi.name '^' num2str(pi.h) ]};
%                    gppiContrasts(conIt).STAT = 'T';
%                    gppiContrasts(conIt).MinEvents = minEvents;
%                    gppiContrasts(conIt).MinEventsPer = [];
%                    gppiContrasts(conIt).c = [];
%                    gppiContrasts(conIt).Prefix = [];
%                    conIt = conIt + 1;
                                      % ALEX CHANGED: NOT NEEDED IS REDUNDANT BEGIN
               end
          end
       end
   end
end

%------------- END CODE --------------