function x = tricond_gen (A_norm, Q, Q2)
    if issparse(Q)
        x = sparse_tricond_gen (A_norm, Q, Q2);
    else
        x =   full_tricond_gen (A_norm, Q, Q2);
    end
end

%!test
%! X = tricond_gen(rand(1,1), [], cast([], 'int8'));
%! myassert (isinf(X));  % similar to rcond([])

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     m = ceil(10*rand);
%!     A = rand(n);  % + 10*eye(n);
%!     B = rand(n,m);
%!     A = cast(A, precision);
%!     B = cast(B, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!         B = sparse(B);
%!     end
%!     %disp({storage, precision, i, n, m})  % DEBUG
%! 
%!     [Q, Q2] = trifactor_gen (A);
%!     rand('state',0);  %  condest invokes rand.
%!     x = tricond_gen (norm(A,1), Q, Q2);
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

