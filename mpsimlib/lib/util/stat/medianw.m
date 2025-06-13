function [ym, ws, n] = medianw (y, w, dim)
%MEDIANW  Weighted median.
% 
% See also:  MEDIAN.

    if (nargin < 3),  dim = [];  end
    ignore_nans = false;
    [ym, ws, n] = nanmedianw (y, w, dim, ignore_nans);
end

