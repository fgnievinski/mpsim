function A = transpose (A)
    A = diag(cell(A));
    A = cellfun(@transpose, A, 'UniformOutput',false);
    A = blockdiag(A);
end

%!test
%! A = blockdiag_sample ();
%! B = transpose(unblockdiag(A));
%! B2 = transpose(A);
%! B3 = unblockdiag(B2);
%! myassert(isequal(B3, B))

