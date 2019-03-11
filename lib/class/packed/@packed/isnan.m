function A = isnan (A)
    A.data = isnan(A.data);
end

%!test
%! A_full = [1 NaN; NaN 1];
%! A = packed(A_full);
%!   myassert(ispacked(A));
%! X_full = isnan(A_full);
%! X = isnan(A);
%! myassert(full(X), X_full)

