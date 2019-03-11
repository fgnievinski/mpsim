function X = triinv_pos (Q, uplow)
    if issparse(Q)
        X = sparse_triinv_pos (Q, uplow);
    else
        X =   full_triinv_pos (Q, uplow);
        X = makeitsymm (X, uplow);
    end
end

%!test
%! % positive-definite matrices:
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     %{storage, uplow, precision, matrix_type, i, n, n2}  % DEBUG
%!     A = gallery(matrix_type, n) + 10*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     [Q, info] = trifactor_pos (A, uplow);
%!     X = triinv_pos (Q, uplow);
%!     X2 = inv(A);
%! 
%!     %X, X2
%!     %temp = X - X2;  max(abs(temp(:)))  % DEBUG
%!     myassert (X, X2, -eps(precision));
%!     if issparse(A),  myassert(issparse(X));  end
%! end
%! end
%! end
%! end
%! end

