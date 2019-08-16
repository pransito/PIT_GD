function parsave(fname,varnames,vars)
% save function for within parfor loop
% fname: filename as str
% varnames: cellstr with names of variables
cmd = ['save(fname,''' varnames{1} ''''];

for vv = 2:length(varnames)
    cmd = [cmd ', ''' varnames{vv} ''''];
end

% finalize command
cmd = [cmd ')'];

% load the vars 
if length(varnames) ~= length(vars)
    error('lengths of varnames and vars does not match')
end
for vv = 1:length(varnames)
    lcmd = [varnames{vv} ' = vars{vv}'];
    eval(lcmd);
end

% save
eval(cmd)

end