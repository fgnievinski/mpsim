function [wavg, ws, n, wm] = nanavgw (obs, weight, dim, ignore_nans)
%NANMEANW  Weighted average, ignoring NaNs.
    if (nargin < 2),  weight = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    robustify = false;
    [wavg, ws, n, wm] = nanavgwr (obs, weight, dim, ignore_nans, robustify);
end

