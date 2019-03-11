function varargout = nanrmseur (obs, std, dim, ignore_nans, robustify)
%NANRMSUR  Uncertainty-weighted root-mean-squared error, robust against outliers, ignoring NaNs.
    if (nargin < 2),  std = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  robustify = [];  end
    detrendit = false;
    [varargout{1:nargout}] = nanstdur (obs, std, dim, ignore_nans, detrendit, robustify);
end

