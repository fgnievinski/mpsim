function rmse = nanrmse_alt (obs, dim, ignore_nans)
%NANRMSE_ALT  Root-mean-squared error, ignoring NaNs; alternative implementation.
    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    detrendit = false;
    rmse = nanstd_alt (obs, dim, ignore_nans, detrendit);
end

