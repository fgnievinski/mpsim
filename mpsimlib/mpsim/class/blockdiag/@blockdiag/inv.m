function A = inv (A)
    A = diag(cell(A));
    A = cellfun(@inv, A, 'UniformOutput',false);
    A = blockdiag(A);
end

