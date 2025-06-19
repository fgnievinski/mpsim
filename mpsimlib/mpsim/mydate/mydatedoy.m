function [doy, year0, num0, dnum] = mydatedoy (varargin)
%MYDATEDOY: Convert epoch to (decimal) day of year.
    [num, year0] = mydatedoy_aux (varargin{:});
    num0 = mydatenum(year0);
    dnum = (num - num0);
    doy = mydateday(dnum);
end

%!test
%! d = [2000 1 1 0 0 0];
%! doy_correct = 1;
%! doy_answer = mydatedoy(mydatenum(d));
%! myassert (doy_answer, doy_correct);

%!test
%! d = [2000 1 30 0 0 0];
%! doy_correct = 30;
%! doy_answer = mydatedoy(mydatenum(d));
%! myassert (doy_answer, doy_correct);

%!test
%! d = [2000 2 1 0 0 0];
%! doy_correct = 32;
%! doy_answer = mydatedoy(mydatenum(d));
%! myassert (doy_answer, doy_correct);

%!test
%! d = [...
%!    2000 1 1 0 0 0
%!    2000 1 30 0 0 0
%!    2000 2 1 0 0 0
%! ];
%! doy_correct = [1; 30; 32];
%! doy_answer = mydatedoy(mydatenum(d))
%! myassert (doy_answer, doy_correct);
