function varargout = nanstdu (obs, std, dim, ignore_nans, detrendit)
%NANSTDU  Uncertainty-weighted standard deviation, ignoring NaNs.
    if (nargin < 2),  std = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5),  detrendit = [];  end
    robustify = false;
    [varargout{1:nargout}] = nanstdur (obs, std, dim, ignore_nans, detrendit, robustify);
end

