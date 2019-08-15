% makes a batch of randperms (gmats) and saves them in the gmat folder
P_base = P;
tmp.pwd = pwd;
cd([cur.path.pwd filesep cur.path.gmat])
for ff = 1:length(P.onlyrpsubs)
    tmp.sub = P.onlyrpsubs(ff);
    make_randperm
    cur_gmat = P.gmat;
    save(['gmat_' '0' num2str(tmp.sub)],'cur_gmat');
    P = P_base;
end
cd(tmp.pwd)