function out = mydateyearabs (in, algorithm)
%MYDATEYEARABS: Convert epoch to absolute (decimal) years.

    if (nargin < 2),  algorithm = 2;  end
    
    switch algorithm
    case 1
        is_diff = false;
        dyear = mydateyear (in, is_diff);
        [~, ~, ~, year0] = mydatebase (is_diff);
        out = year0 + dyear;
    case 2
        [doy, year0, num0] = mydatedoy (in);
        year_duration = mydatenum(year0+1) - num0;
        year_duration_day = mydateday(year_duration);
        day_diff = doy - 1;  % as mydatedoy([2015 01 01  00 00 00]) == 1.0
        out = year0 + day_diff ./ year_duration_day;
    end
end

%!test
%! datevec_in = [...
%!   2015 12 31  00 00 00
%!   2015 12 31  12 00 00
%!   2015 12 31  23 00 00
%!   2015 12 31  24 00 00
%!   2016 01 01  00 00 00
%!   2016 01 01  01 00 00
%!   2016 01 01  12 00 00
%!   2016 01 01  24 00 00
%! ];
%! 
%! datenum_in = mydatenum(datevec_in)
%! dateyear_out = mydateyearabs(datenum_in)
%! datenum_out = mydateyearabsi(dateyear_out)
%! datevec_out = mydatevec(datenum_out)
%! 
%! datenum_out - datenum_in  % DEBUG
%! datevec_out - datevec_in  % DEBUG
%! myassert(datenum_out, datenum_in, sqrt(eps()))
%! 
%! datenum_in_diff = diff(datenum_in)
%! datenum_out_diff = diff(datenum_out)
%! myassert(datenum_out_diff, datenum_in_diff, sqrt(eps()))
%! 
%! dateyear_out_diff = diff(dateyear_out)
