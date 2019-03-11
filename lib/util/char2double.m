function num = char2double (txt)
    if all(txt(:) == ' ')
      % early exit in case of common input:
      num = NaN(size(txt));
      return
    end
    num = double(txt) - double('0');
    num(~(0 <= num & num <= 9)) = NaN;
end

%!test
%! num2 = char2double (['123';'4 6'])
%! myassert(num2, [1 2 3; 4 NaN 6]);

%!test
%! txt = [...
%!   ' 84  '
%!   ' 96  '
%!   ' 95  '
%!   ' 84  '
%!   ' 97  '
%!   ' 96  '
%!   ' 74  '
%!   ' 66  '
%! ];
%! num = [...
%!   NaN 8 4 NaN NaN
%!   NaN 9 6 NaN NaN
%!   NaN 9 5 NaN NaN
%!   NaN 8 4 NaN NaN
%!   NaN 9 7 NaN NaN
%!   NaN 9 6 NaN NaN
%!   NaN 7 4 NaN NaN
%!   NaN 6 6 NaN NaN
%! ];
%! num2 = char2double (txt)
%! myassert(num2, num)
