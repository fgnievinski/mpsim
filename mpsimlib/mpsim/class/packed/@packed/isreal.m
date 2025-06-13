function answer = isreal (A)
    answer = isreal (A.data);
end

%!test
%! A = packed([1+i, 2+i, 3+i], 'sym', 'u');
%! myassert (ispacked(A));
%! myassert (~isreal(A));

%!test
%! A = packed([1, 2, 3], 'sym', 'u');
%! myassert (ispacked(A));
%! myassert (isreal(A));

%!test
%! A = packed(complex(randsym(2)));
%! myassert (ispacked(A));
%! myassert (~isreal(A));

