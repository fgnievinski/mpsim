function num = mydatedoyi (doy, year0)
%MYDATEDOYI: Convert from (decimal) day of year (to epoch internal format).
    if (nargin < 2) || isempty(year0),  year0 = getel(datevec(now()), 1);  end
    myassert(length(year0)==length(doy) || isscalar(year0))
    num0 = mydatenum(year0);  % epoch corresponding to the beginning to that year.
    dnum = mydatedayi(doy);
    num = num0 + dnum;
end

%!test
%! vec = [2000 1 1 0 0 0];
%! num = mydatenum(vec);
%! doy = 1;
%! year = 2000;
%! num2 = mydatedoyi(doy, year);
%! myassert (num2, num);

%!test
%! vec = [2000 1 30 0 0 0];
%! num = mydatenum(vec);
%! doy = 30;
%! year = 2000;
%! num2 = mydatedoyi(doy, year);
%! myassert (num2, num);

%!test
%! vec = [2000 2 01 0 0 0];
%! num = mydatenum(vec);
%! doy = 32;
%! year = 2000;
%! num2 = mydatedoyi(doy, year);
%! myassert (num2, num);

