function answer = spdiag (input)
    n = numel(input);
    input = reshape(input, [n 1]);
    answer = spdiags(input, 0, n, n);
end

%!test
%! input = rand(3,1);
%! answer1 = diag(sparse(input));
%! answer2 = spdiag(input);
%! myassert(answer2, answer1)
