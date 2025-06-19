function out = mydateyearabsi (in, algorithm)
%MYDATEYEARABSI: Convert from absolute (decimal) years (to epoch internal format).

    if (nargin < 2),  algorithm = 2;  end
    
    siz = size(in);
    in = in(:);
    
    switch algorithm
    case 1
        is_diff = false;
        [~, ~, ~, byear] = mydatebase (is_diff);
        dyear = in - byear;
        out = mydateyeari (dyear, is_diff);
    case 2
        dyear = in;
        nyear = floor (dyear);
        fyear = dyear - nyear;
        year_duration = mydatenum(nyear+1) - mydatenum(nyear);
        year_duration_day = mydateday(year_duration);
        %year_duration_day = 365.25;  % WRONG!
        fday = fyear .* year_duration_day;
        doy = fday + 1;  % as mydatedoy([2015 01 01  00 00 00]) == 1.0
        out = mydatedoyi (doy, nyear);
    end
    
    out = reshape(out, siz);
end

%!test
%! test mydateyearabs
