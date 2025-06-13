function rmss = nanrmssr (num_params, resid, dim, ignore_nans, robustify)
%NANRMSSR  Parameter-scaled root-mean-squared error, robust against outliers, ignoring NaNs.
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  robustify = [];  end
    std = 1;
    rmss = nanrmssur (num_params, resid, std, dim, ignore_nans, robustify);
end

