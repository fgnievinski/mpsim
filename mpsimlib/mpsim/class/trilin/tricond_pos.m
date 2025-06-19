function x = tricond_pos (A_norm, Q, uplow)
    if issparse(Q)
        x = sparse_tricond_pos (A_norm, Q, uplow);
    else
        x =   full_tricond_pos (A_norm, Q, uplow);
    end
end

%!test
%! X = tricond_pos(rand(1,1), [], 'U');
%! myassert (isinf(X));  % similar to rcond([])

%!test
%! % positive-definite matrices:
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     %{uplow, precision, matrix_type, i, n, n2}  % DEBUG
%!     A = gallery(matrix_type, n) + 10*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     Q = trifactor_pos (A, uplow);
%!     rand('state',0);  %  condest invokes rand.
%!     x = tricond_pos (norm(A,1), Q, uplow);
%!     if issparse(A)
%!         rand('state',0);  %  condest invokes rand.
%!         x2 = 1./condest(A);
%!     else
%!         x2 = rcond(A);
%!     end
%!     %disp({storage, precision, uplow, i, n, x, x2, x-x2})  % DEBUG
%! 
%!     %myassert (0 <= x && x <= 1);
%!     myassert (-10*eps(precision) <= x);
%!     myassert (x <= 1+10*eps(precision));
%!     myassert (x, x2, -10*eps(precision));
%! end
%! end
%! end
%! end
%! end

