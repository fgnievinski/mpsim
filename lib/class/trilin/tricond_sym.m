function x = tricond_sym (A_norm, Q, Q2, uplow)
    if issparse(Q)
        x = sparse_tricond_sym (A_norm, Q, Q2, uplow);
    else
        x =   full_tricond_sym (A_norm, Q, Q2, uplow);
    end
end

%!test
%! X = tricond_sym(rand(1,1), [], cast([], 'int8'), 'U');
%! myassert (isinf(X));  % similar to rcond([])

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
%!     rand('state',0);  %  condest invokes rand.
%!     x = tricond_sym (norm(A,1), Q, Q2, uplow);
%!     if issparse(A)
%!         rand('state',0);  %  condest invokes rand.
%!         x2 = 1./condest(A);
%!     else
%!         x2 = rcond(A);
%!     end
%! 
%!     %[x, x2]  % DEBUG
%!     myassert (0 <= x && x <= 1);
%!     myassert (x, x2, -10*eps(precision));
%! end
%! end
%! end
%! end
%! end
%! warning('on', 'trilin:trifacotor_sym:sparse');


