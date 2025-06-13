function X = triinv_sym (Q, Q2, uplow)
    if issparse(Q)
        X = sparse_triinv_sym (Q, Q2, uplow);
    else
        X =   full_triinv_sym (Q, Q2, uplow);
        X = makeitsymm (X, uplow);
    end
end

%!test
%! % symmetric indefinite matrices:
%! warning('off', 'trilin:trifacotor_sym:sparse');
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     A = gallery(matrix_type, n) - 10*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     [Q, Q2] = trifactor_sym (A, uplow);
%!     X = triinv_sym (Q, Q2, uplow);
%!     X2 = inv(A);
%!
%!     %{precision, i, n, n2, norm(X - A\B)}  % DEBUG
%!     myassert (X, X2, -10*eps(precision));
%!     [R, p] = chol(A);
%!     if (p == 0), error('test matrix should NOT be pos-def.');  end
%!     if issparse(A),  myassert(issparse(X));  end
%! end
%! end
%! end
%! end
%! end
%! warning('on', 'trilin:trifacotor_sym:sparse');


