function p = nanrfitslm (x, y, n_max)
%NANRFITSLM: Robust fit of simple linear regression model (ignoring NaNs).
% 
% SEE ALSO: polyfit.

    if (nargin < 3),  n_max = [];  end
    s = nanrslope (x, y, n_max);  % robust slope
    r = y - s*x;  % residuals (preliminary)
    i = nanmedian (r);  % robust intercept
    p = [s i];  % polynomial coefficients
end
