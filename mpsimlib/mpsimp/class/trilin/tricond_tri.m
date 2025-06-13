function x = tricond_tri (A_norm, Q, uplow)
    if issparse(Q)
        x = sparse_tricond_tri (A_norm, Q, uplow);
    else
        x =   full_tricond_tri (A_norm, Q, uplow);
    end
end

%!test
%! X = tricond_tri(rand(1,1), [], 'U');
%! myassert (isinf(X));  % similar to rcond([])

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for i=1:10
%!     n  = ceil(10*rand);
%!     A = rand(n)+10*eye(n);
%!     A = cast(A, precision);
%!     A = triuplow(A, uplow);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     Q = trifactor_tri (A, uplow);
%!     rand('state',0);  %  condest invokes rand.
%!     x = tricond_tri (norm(A,1), Q, uplow);
%!     if issparse(A)
%!         rand('state',0);  %  condest invokes rand.
%!         x2 = 1./condest(A);
%!     else
%!         x2 = rcond(A);
%!     end
%!     %disp({storage, precision, uplow, i, n, x, x2, x-x2})  % DEBUG
%! 
%!     myassert (x, x2, -10*eps(precision));
%! end
%! end
%! end
%! end

