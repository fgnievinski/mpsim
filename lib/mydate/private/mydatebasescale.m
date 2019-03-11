function [factor2matlab, factor2sec] = mydatebasescale ()
%MYDATEBASE: Define base scale factor for internal use in mydate functions.
    factor2matlab = 60 * 60 * 24;  % matlab's datenum is in decimal days, mydatenum is in seconds.
    factor2sec = 1;  % from mydatenum scale to seconds.
end

%!test
%! [vec, num, factor] = mydatebase ();
%! assert(isequal(size(vec), [1,6]))
%! assert(isscalar(num))
%! assert(isscalar(factor))

