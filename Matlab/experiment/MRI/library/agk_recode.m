% function to recode x, given a source vector y and a translated vector z
function x=agk_recode(x,y,z)
for ii = 1:length(x)
    done = 0;
    for jj = 1:length(y)
        if x(ii) == y(jj)
            x(ii) = z(jj);
            done = 1;
        end
        if done == 1 
            break
        end
    end
end
  
