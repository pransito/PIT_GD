% function that checks whether adequate physio data is there
function agk_PDT_check_physio(physio_data,path_data)

% get to the right location
comp_name = getenv('USERNAME');
cd(path_data);

% check if there is data for subs
subs_with_good_physio_data = {};
[r,l] = size(physio_data);
ct    = 0;
for ii = 1:r
    good_data = 1;
    for jj = 2:l
        % check for missing
        if isempty(physio_data{ii,jj})
            good_data = 0;
            break
        end

        % check for nan
        if ~any(isnan(physio_data{ii,jj}{1}))
        else
            good_data = 0;
            break
        end
    end
    if good_data == 1
        ct = ct + 1;
        subs_with_good_physio_data{ct,1} = physio_data{ii};
    end
end

T = cell2table(subs_with_good_physio_data);
writetable(T,'good_physio_data.txt','Delimiter',' ')  
