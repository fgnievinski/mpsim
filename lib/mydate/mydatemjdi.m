function [epoch, jd] = mydatemjdi (mjd)
%MYDATEMJDI: Convert from (decimal) modified Julian day (to epoch internal format).
    jd = mjd + 2400000.5;
    epoch = mydatejdi (jd);
end

%!test
%! num = mydatenum([1858 11 17  0 0 0]);
%! num2 = mydatemjdi(0);
%! myassert (num2, num)

