function answer = isup (A)
    answer = strcmp(A.uplow, 'u');
end

%!test
%! n = 10;
%! temp = rand(n);
%! temp2 = triu(temp);
%! A = packed(temp2);
%! myassert (ispacked(A));
%! myassert (isup(A));

%!test
%! A = packed;
%! myassert (ispacked(A));
%! myassert (~isup(A));

