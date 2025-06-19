function A = uminus (A)
    A.data = uminus(A.data);
end

%!test
%! % uminus()
%! A_full = eye(3);
%! A = packed(A_full);
%!   myassert(ispacked(A));
%! X_full = - A_full;
%! X = - A;
%! myassert(full(X), X_full)

