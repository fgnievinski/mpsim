function X = triinv_tri (Q, uplow)
    if issparse(Q)
        X = sparse_triinv_tri (Q, uplow);
    else
        X =   full_triinv_tri (Q, uplow);
        X = triuplow(X, uplow);
    end
end

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for i=1:10
%!     n  = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     A = rand(n)+10*eye(n);
%!     A = cast(A, precision);
%!     A = triuplow(A, uplow);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%!     %disp({precision, uplow, i, n, n2})  % DEBUG
%! 
%!     Q = trifactor_tri (A, uplow);
%!     X = triinv_tri (Q, uplow);
%!     X2 = inv(A);
%! 
%!     myassert (X, X2, -10*eps(precision));
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end

