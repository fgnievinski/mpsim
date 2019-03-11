function A = triu (A)
    A = cellfun(@triu, diag(cell(A)), ...
        'UniformOutput',false);
    A = blockdiag(A);
end


