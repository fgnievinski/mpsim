function A = power (A, p)
    A = cellfun(@(a) a.^p, diag(cell(A)), ...
        'UniformOutput',false);
    A = blockdiag(A);
end

