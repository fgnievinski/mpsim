function rmss = nanrmssr2 (num_params, resid, dim, ignore_nans, robustify)
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  robustify = [];  end
    std = 1;
    rmss = nanrmssur2 (num_params, resid, std, dim, ignore_nans, robustify);
end

