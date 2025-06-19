function varargout = nanstdr_alt (obs, dim, ignore_nans, detrendit)
%NANSTDR_ALT  Standard deviation, robust against outliers, ignoring NaNs; alternative implementation.
    if (nargin < 2),  dim = [];  end
    if (nargin < 3),  ignore_nans = [];  end
    if (nargin < 4),  detrendit = [];  end
    std = [];
    [varargout{1:nargout}] = nanstdur (obs, std, dim, ignore_nans, detrendit);
end


