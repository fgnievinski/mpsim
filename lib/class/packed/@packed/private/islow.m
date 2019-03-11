function answer = islow (A)
    answer = strcmp(A.uplow, 'l');
end

%!test
%! n = 10;
%! temp = rand(n);
%! temp2 = tril(temp);
%! A = packed(temp2);
%! myassert (ispacked(A));
%! myassert (islow(A));

%!test
%! A = packed;
%! myassert (ispacked(A));
%! myassert (~islow(A));

