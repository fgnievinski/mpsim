function answer = nnz (A)
    answer = nnz(cell(A));
end

%!test
%! temp = blockdiag(1, zeros(2), eye(3));
%! myassert (nnz(temp), 4);

%!test
%! temp = blockdiag;
%! myassert (nnz(temp), 0)

