function rmse = nanrmser (obs, dim, ignore_nans)
%NANRMSE  Root-mean-squared error, robust against outliers, ignoring NaNs.
% 
% See also:  RMSER, NANSTDR.

    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    detrendit = false;
    rmse = nanstdr (obs, dim, ignore_nans, detrendit);
end

