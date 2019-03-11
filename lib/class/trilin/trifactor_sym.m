function [Q, Q2] = trifactor_sym (A, uplow)
    if (nargin < 2),  uplow = [];  end
    if issparse(A)
        [Q, Q2] = sparse_trifactor_sym (A, uplow);
    else
        [Q, Q2] =   full_trifactor_sym (A, uplow);
    end
end

%!test
%! [Q, p] = trifactor_sym([], 'u');
%! myassert (isempty(Q));
%! myassert (isempty(p));

%!test
%! [Q, p] = trifactor_sym(1, 'u');
%! myassert (Q, 1);
%! myassert (p, 1);

%!test
%! warning('off', 'trilin:trifacotor_sym:sparse');
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     %{storage, uplow, precision, matrix_type, i}  % DEBUG
%!     n = ceil(10*rand);
%!     A = gallery(matrix_type, n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     [Q, p] = trifactor_sym (A, uplow);
%! 
%!     myassert (size(Q), [n, n]);
%!     myassert (isfloat(Q));
%!     if strcmp(storage, 'full'),  myassert (isinteger(p));  end
%!     %Q, pause
%!     % I don't know against what standard I can compare 
%!     % trifactor_sym's results.
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end
%! end
%! warning('on', 'trilin:trifacotor_sym:sparse');

%!test
%! % trifactor_sym reads and writes only in the upper or lower triangular 
%! % part of A -- it assumes A is symmetric, even if that's not the case.
%! A = rand(4);
%! A = rand(4);
%! %trifactor_sym(A), trifactor_sym(triu(A))  % DEBUG
%! myassert (triu(trifactor_sym(A, 'upper')), triu(trifactor_sym(triu(A), 'uppwer')))

