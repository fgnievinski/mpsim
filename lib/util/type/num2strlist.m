function str_out = num2strlist (num, format, sep)
    if (nargin < 2) || isempty(format),  format = '%.0f';  end
    if (nargin < 3) || isempty(sep),  sep = ', ';  end
    str_out = sprintf([format sep], num);
    str_out(end-numel(sep)+1:end) = [];  % remove dangling ', '
end

%!test
%! num = [1; 2; 10];
%! str = '1, 2, 10';
%! str2 = num2strlist(num);
%! str2, str  % DEBUG
%! myassert(str2, str)

