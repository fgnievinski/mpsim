function [d, c, b] = invargsort (a, varargin)
    [c, b] = argsort (a, varargin{:});
    %e = argsort (c, varargin{:});  % WRONG!
    varargin(cellfun(@ischar, varargin)) = [];  % remove mode arg.
    d = argsort (c, varargin{:});
end

%!test
%! a = [1 0 8 9 3 2];
%! b = [0 1 2 3 8 9];
%! 
%! c = [2 1 6 5 3 4];
%! d = [2 1 5 6 4 3];
%! 
%! [d2, c2] = invargsort(a);
%! 
%! %[c; c2]  % DEBUG
%! %[d; d2]  % DEBUG
%! 
%! myassert(c2, c)
%! myassert(d2, d)

%!test
%! a = [1 0 8 9 3 2];
%! %   [1 2 3 4 5 6]
%! b = [9 8 3 2 1 0];
%! 
%! c = [4 3 5 6 1 2];
%! d = [5 6 2 1 3 4];
%! 
%! [d2, c2] = invargsort(a, 'descend');
%! 
%! %[c; c2]  % DEBUG
%! %[d; d2]  % DEBUG
%! 
%! myassert(c2, c)
%! myassert(d2, d)

%!test
%! % invargsort()
%! n = 5;
%! a = rand(1,5);
%! b = sort(a);
%! 
%! a2 = getel(b, argsort(argsort(a)));
%! %[a2; a]  % DEBUG
%! myassert(a2, a)

