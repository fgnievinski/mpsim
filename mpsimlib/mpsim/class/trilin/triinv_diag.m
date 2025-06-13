function X = triinv_diag (Q)
    X = 1./Q;
end

%!test
%! n = 4;
%! n2 = 5;
%! A = rand.*eye(n);
%! Q = trifactor_diag (A);
%! X = triinv_diag (Q);
%! X2 = diag(inv(A));
%! %X, X2
%! myassert (X, X2, -10*eps);

%!test
%! A = rand(1,1);
%! Q = trifactor_diag (A);
%! X = triinv_diag (Q);
%! X2 = diag(inv(Q));
%! %X, X2
%! myassert (X, X2, -10*eps);

