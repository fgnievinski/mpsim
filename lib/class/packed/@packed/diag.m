function answer = diag (A)
    ind = find(speye(size(A)));
    s.type = '()';
    s.subs = {ind};
    answer = subsref(A, s);
end

%!test
%! % uminus()
%! A_full = eye(3);
%! A = packed(A_full);
%!   myassert(ispacked(A));
%! answer_full = diag(A_full);
%! answer = diag(A);
%! myassert(~ispacked(answer))
%! myassert(answer, answer_full)

