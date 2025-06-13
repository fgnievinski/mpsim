function e = invsort (c, varargin)
    [d, e] = sort(c, varargin{:}); %#ok<ASGLU>
end

%!test
%! a = [1 0 8 9 3 2];
%! b = [0 1 2 3 8 9];
%! 
%! c = [2 1 6 5 3 4];
%! e = [2 1 5 6 4 3];
%! 
%! c2 = argsort(a);
%! e2 = invsort(c2);
%! 
%! %[c; c2]  % DEBUG
%! %[e; e2]  % DEBUG
%! 
%! myassert(c2, c)
%! myassert(e2, e)

%!test
%! n = 5;
%! a = rand(1,5);
%! b = sort(a);
%! 
%! a2 = getel(b, invsort(argsort(a)));
%! %[a2; a]  % DEBUG
%! myassert(a2, a)

