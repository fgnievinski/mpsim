function X = triinv_gen (Q, Q2)
    if issparse(Q)
        X = sparse_triinv_gen (Q, Q2);
    else
        X =   full_triinv_gen (Q, Q2);
    end
end

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     m = ceil(10*rand);
%!     A = rand(n) + 10*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%!     %disp({storage, precision, i, n, m})  % DEBUG
%! 
%!     [Q, Q2] = trifactor_gen (A);
%!     X = triinv_gen (Q, Q2);
%!     X2 = inv(A);
%! 
%!     %temp = X - X2;  max(abs(temp(:)))  % DEBUG
%!     myassert (X, X2, -100*eps(precision));
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end

