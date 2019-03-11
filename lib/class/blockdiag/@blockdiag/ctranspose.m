function A = ctranspose (A)
    A = diag(cell(A));
    A = cellfun(@ctranspose, A, 'UniformOutput',false);
    A = blockdiag(A);
end

%!test
%! A = blockdiag_sample ();
%! B = ctranspose(unblockdiag(A));
%! B2 = ctranspose(A);
%! B3 = unblockdiag(B2);
%! myassert(isequal(B3, B))

