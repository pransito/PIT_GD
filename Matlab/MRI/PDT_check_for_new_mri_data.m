% Script checks if there are new subjects on S:
% Tells which subjects are new and schould be copied to external HD
% Copying should be done by hand in Explorer, it is faster
% otherwise use a OS command in future

cur_source = 'S:\AG\AG-Spielsucht2\Daten\VPPG_Daten\MRT';
cur_target = 'E:\Daten\VPPG\MRT\MRT';
cd(cur_source)
all_subs  = cellstr(ls('VPPG*'));
cd(cur_target)
all_subst = cellstr(ls('VPPG*'));

for ii = 1:length(all_subs)
    cur_sub = all_subs(ii);
    if strfind(cur_sub{1},'VPPGX')
        continue
    end
    if (sum(strcmp(cur_sub{1},all_subst))== 0)
        disp([cur_sub{1} ' is not in target. Please copy it to external HD in Explorer.']);
        cur_s = [cur_source filesep cur_sub{1}];
        cur_t = [cur_target filesep cur_sub{1}];
        %copyfile(cur_s,cur_t);
    end
end