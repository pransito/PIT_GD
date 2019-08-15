function agk_physio_error_reporting(subs)

for ii = 1:length(subs)
    for jj = 2:length(subs(ii).error)
        if isempty(strfind(subs(ii).error{jj},'Ok. NO nans'))
            [a,b] = fileparts(subs(ii).name);
            disp([b ' ' subs(ii).error{jj}]);
        else
            
        end
    end
end