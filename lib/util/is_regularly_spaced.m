function answer = is_regularly_spaced (x, tol)
% see also: is_contiguous_vector
    if (nargin < 2),  tol = [];  end
    answer = is_uniform (diff(x), tol);
end

%!test
%! myassert(is_regularly_spaced(1:10))
%! myassert(is_regularly_spaced(10:-1:1))
%! myassert(~is_regularly_spaced([1 2 5]))
%! myassert(is_regularly_spaced([0.9 1 1.1], 0.1))
%! myassert(is_regularly_spaced([]))
%! myassert(is_regularly_spaced(rand()))
