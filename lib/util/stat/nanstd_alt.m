function varargout = nanstd_alt (obs, dim, ignore_nans, detrendit)
%NANSTD_ALT  Standard deviation, ignoring NaNs; alternative implementation.
    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    if (nargin < 4),  detrendit = [];  end
    std = [];
    robustify = false;
    [varargout{1:nargout}] = nanstdur (obs, std, dim, ignore_nans, detrendit, robustify);
end

