function B = diag (A)
    a = zeros(size(A));
    a(:) = 1:numel(A);
    b = diag(a);
    B = cell(size(b));
    ind = (b ~= 0);
    B(ind) = A(b(ind));
end

% test('diag', 'class')

%!test
%! % matrix to vector:
%! A2 = rand(3,3);
%! A = num2cell(A2);
%! B2 = diag(A2);
%! B = diag(A);
%! B3 = cell2mat(B);
%! myassert(size(B3), size(B))
%! myassert(B3, B2)
%! myassert(B3, B2)

%!test
%! % vector to matrix:
%! A2 = rand(3,1);
%! A = num2cell(A2);
%! B2 = diag(A2);
%! B = diag(A);
%! ind = cellfun(@isempty, B);
%! B(ind) = {0};
%! B3 = cell2mat(B);
%! myassert(size(B3), size(B))
%! myassert(B3, B2)
%! myassert(B3, B2)

