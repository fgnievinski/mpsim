function [factor, Num, dNum, dyear, factor0] = mydatebase (is_diff)
%MYDATEBASE: Define base information for internal use in mydate functions.
    if (nargin < 1) || isempty(is_diff),  is_diff = false;  end
    if is_diff
        dyear = 0;
        dvec = zeros(1,6);
    else
        dyear = 2000;
        dvec = [0 1 1  0 0 0];
    end
    dNum = datenum(dvec);
    vec = dvec;  vec(1) = dyear;
    Num = datenum(vec);
    [factor, factor0] = mydatebasescale ();
end

%!test
%! [vec, num, factor] = mydatebase ();
%! assert(isequal(size(vec), [1,6]))
%! assert(isscalar(num))
%! assert(isscalar(factor))

