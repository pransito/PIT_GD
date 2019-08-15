% function to check if all contrasts are there and estimable in single
% subject model(s); if not, will try to resort to one of the two sessions
% update cons; if not it will give error

function error_message = agk_PDT_chkcons(cur_sub,ss_name,des_num_cons)

% get into folder and load SPM.mat
cd(cur_sub)
cd('MRT\NIFTI\PDT\results')
try
    cd(ss_name')
catch
    msg           = [cur_sub ': ss design not there.'];
    error_message = msg;
    disp(msg)
    return
end
load('SPM.mat')

% get number of sessions
num_sess = length(SPM.Sess);

% get all experimental regressors
design_regressors = SPM.xX.name';
R_ids = regexp(design_regressors,'R[1-9]|constant');
R_ids = cellfun(@isempty,R_ids);

% get the number of desired con regressors
num_des_cons = sum(R_ids)/num_sess;

% compare to number of existing cons
test_res = length(SPM.xCon) == num_des_cons;

if test_res & (des_num_cons == num_des_cons)
    msg = [cur_sub ': All ss cons are there as expected from des matrix'];
    disp(msg)
    error_message = msg;
else
    msg = [cur_sub ': Ss cons are missing. Checking design matrix.'];
    disp(msg)
    error_message = msg;
    var0_regr = (var(SPM.xX.X) == 0);
end
    



