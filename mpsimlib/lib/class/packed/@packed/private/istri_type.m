function answer = istri_type (A)
    answer = strcmp(A.type, 'tri');
end

%!test
%! n = 10;
%! temp = rand(n);
%! temp2 = triu(temp, +1);
%! A = packed(temp2);
%! myassert (ispacked(A));
%! myassert (istri_type(A));

%!test
%! A = packed([1 2; 0 1]);
%! myassert (ispacked(A));
%! myassert (istri_type(A));

%!test
%! A = packed;
%! myassert (ispacked(A));
%! myassert (~istri_type(A));

