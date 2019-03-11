function answer = issym_type (A)
    answer = strcmp(A.type, 'sym');
end

%!test
%! n = 10;
%! temp = rand(n);
%! temp2 = triu(temp, +1) + triu(temp, +1)' + diag(diag(temp));
%! A = packed(temp2);
%! myassert (ispacked(A));
%! myassert (issym_type(A));

%!test
%! A = packed([1 2; 2 1]);
%! myassert (ispacked(A));
%! myassert (issym_type(A));

%!test
%! A = packed;
%! myassert (ispacked(A));
%! myassert (~issym_type(A));

