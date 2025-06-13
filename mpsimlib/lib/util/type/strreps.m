function str = strreps (str, old, new, varargin)
    str = strrep (str, old, new);
    if (nargin < 4),  return;  end
    str = strreps (str, varargin{:});
end

%!test
%! str_in = 'abcdef';
%! old1 = 'a';  new1 = '1';
%! old2 = 'b';  new2 = '2';
%! old3 = 'c';  new3 = '3';
%! str_out = strrep(strrep(strrep(str_in, ...
%!     old1,new1), old2,new2), old3,new3);
%! str_out2 = strreps(str_in, ...
%!     old1,new1, old2,new2, old3,new3);
%! %str_out, str_out2  % DEBUG
%! myassert(str_out2, str_out)

%!test
%! % cell array input:
%! str_in = {'abcdef', 'asbd'};
%! old1 = 'a';  new1 = '1';
%! old2 = 'b';  new2 = '2';
%! old3 = 'c';  new3 = '3';
%! str_out = strrep(strrep(strrep(str_in, ...
%!     old1,new1), old2,new2), old3,new3);
%! str_out2 = strreps(str_in, ...
%!     old1,new1, old2,new2, old3,new3);
%! %str_out, str_out2  % DEBUG
%! myassert(str_out2, str_out)

