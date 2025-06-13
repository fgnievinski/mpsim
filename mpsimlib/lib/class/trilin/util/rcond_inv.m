% use rcond(X) in case you don't need the inverse for anything else.
function answer = rcond_inv (X_inv, X)
    answer = rcond_inv2 (X_inv, norm(X,1));
end

%!test
%! X = rand(10,10);
%! X_inv = inv(X);
%! r = rcond(X);
%! r2 = rcond_inv(X_inv, X);
%! %[r, r2, r-r2]  % DEBUG
%! myassert(r, r2, -sqrt(eps))

