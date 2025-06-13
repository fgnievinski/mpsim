function rmss = nanrmss (num_params, resid, dim, ignore_nans)
%NANRMSS  Parameter-scaled root-mean-squared error, ignoring NaNs.
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    robustify = false;
    rmss = nanrmssr (num_params, resid, dim, ignore_nans, robustify);
end

