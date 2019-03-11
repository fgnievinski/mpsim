function answer = isempty (A)
    answer = isempty(A.data) && isempty(A.type);
end

%!test
%! A = packed(eye(2,2));
%! myassert (~isempty(A));

%!test
%! A = packed;
%! myassert (isempty(A));

%!test
%! A = packed([]);
%! myassert (isempty(A));

