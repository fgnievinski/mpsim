function A = tril (A)
    A = cellfun(@tril, diag(cell(A)), ...
        'UniformOutput',false);
    A = blockdiag(A);
end


