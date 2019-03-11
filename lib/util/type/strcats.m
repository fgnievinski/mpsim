function out = strcats (varargin)
%STRCATS  Concatenates character strings, including trailing spaces.
% 
% See also:  STRCAT

  is_cell = cellfun(@iscell, varargin);
  varargin(~is_cell) = cellfun2(@cellstrs, varargin(~is_cell));
  c = char(intmax('int8'));
  varargin = cellfun2(@(x) strrep(x, ' ', c), varargin);
  out = strcat(varargin{:});
  out = strrep(out, c, ' ');
  if none(is_cell),  out = char(out);  end
end

%%
function x = cellstrs (x)
  if iscellstr(x),  return;  end
  c = char(intmax('int8'));
  %in = strrep(in, ' ', c);  % WRONG!
  x(x == ' ') = c;
  x = cellstr(x);
  x = strrep(x, c, ' ');
end

%!test
%! a = 'hello  ';
%! b = 'goodbye';
%! 
%! using_strcat = strcat(a, b);
%! using_strcats = strcats(a, b);
%! using_arrayop = [a, b];
%! 
%! myassert(using_strcats, using_arrayop)

%!test
%! strcats(' ', get(gca(), 'YTickLabel'));

%!test
%! myassert(strcats(' ', {'a','b'}), {' a',' b'})
