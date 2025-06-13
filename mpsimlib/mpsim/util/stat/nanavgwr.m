function [wavg, ws, n, wm] = nanavgwr (obs, weight, dim, ignore_nans, robustify)
%NANMEANW  Weighted average, ignoring NaNs, optionally robust against outliers.
    if (nargin < 2),  weight = [];  end
    if (nargin < 3),  dim = [];  end
    if (nargin < 4),  ignore_nans = [];  end
    if (nargin < 5) || isempty(robustify),  robustify = true;  end 
    if robustify,  myavg = @nanmedianw;  else  myavg = @nanmeanw;  end
    [wavg, ws, n, wm] = myavg (obs, weight, dim, ignore_nans);
end

