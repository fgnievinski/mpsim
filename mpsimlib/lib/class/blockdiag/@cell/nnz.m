function answer = nnz (A)
    temp = cellfun(@nnz, A);
    answer = sum(temp(:));
end

%!test
%! temp = {eye(3), eye(5)};
%! myassert (nnz(temp), 8);

