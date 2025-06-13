function rmse = rmser (obs, dim)
%NANRMSE  Root-mean-square error, robust against outliers.
% 
% See also:  RMSE, STDR.

    if (nargin < 2),  dim = [];  end
    detrendit = false;
    rmse = stdr (obs, dim, detrendit);
end

