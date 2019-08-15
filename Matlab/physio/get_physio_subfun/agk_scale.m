% scales all columns of M; scaling and centering; if nothing is provided
% then both will be done;

function Ms = agk_scale(M,varargin)
Ms = [];
if numel(varargin) == 1
    stds = varargin{1};
    mns  = zeros(size(M,2));
elseif numel(varargin) == 2
    stds = varargin{1};
    mns  = varargin{2};
else
    stds = std(M);
    mns  = mean(M);
end

for ii = 1:size(M,2)
    Ms(:,ii) = (M(:,ii)-mns(ii))/stds(ii);
end

end