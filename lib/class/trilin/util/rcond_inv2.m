% use rcond(X) in case you don't need the inverse for anything else.
function answer = rcond_inv2 (X_inv, X_norm)
    answer = 1/(norm(X_inv,1) * X_norm);
end

%!test
%! % rcond_inv2()
%! test('rcond_inv')

