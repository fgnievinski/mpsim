function varargout = nanrmseu (obs, std, dim, ignore_nans)
%NANRMSU  Uncertainty-weighted root-mean-squared error, ignoring NaNs.
    if (nargin < 2),  std = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    detrendit = false;
    [varargout{1:nargout}] = nanstdu (obs, std, dim, ignore_nans, detrendit);
end


