function A = uminus (A)
    A = cellfun(@uminus, diag(cell(A)), ...
        'UniformOutput',false);
    A = blockdiag(A);
end

