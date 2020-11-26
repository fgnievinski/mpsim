function p = rfitslm (x, y)
%RFITSLM: Robust fit of simple linear regression model.
% 
% SEE ALSO: polyfit, nanrfitslm.

    s = rslope (x, y);  % robust slope
    r = y - s*x;  % residuals (preliminary)
    i = median (r);  % robust intercept
    p = [s i];  % polynomial coefficients
end
