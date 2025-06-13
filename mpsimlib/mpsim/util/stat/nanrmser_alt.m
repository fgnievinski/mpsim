function rmse = nanrmser_alt (obs, dim, ignore_nans)
%NANRMSER_ALT  Root-mean-squared error, robust against outliers, ignoring NaNs; alternative implementation.
    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    detrendit = false;
    rmse = nanstdr_alt (obs, dim, ignore_nans, detrendit);
end

