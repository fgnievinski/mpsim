function num = mydatestri (str, format)
%MYDATESTR: Convert from text character string (to epoch in internal format).
    if (nargin < 2) || isempty(format),  format = 'yymmmdd';  end
    if isempty(str),  num = zeros(0,1);  return;  end
    num2 = datenum(str, format);
    %vec2 = datevec(num2)
    %num = mydatenum(vec2);
    [factor0, num0] = mydatebase();
    num = (num2 - num0) * factor0;
end

%!test
%! format = 'ddmmmyy';
%! vec = datevec(now());
%! vec(4:6) = 0;
%! num = mydatenum(vec);
%! str = mydatestr(num, format);
%! numb = mydatestri(str, format);
%! numc = mydatestri(lower(str), format);
%! %num, numb, numc, numb-num, numc-num  % DEBUG
%! myassert(numb, num)
%! myassert(numc, num)

