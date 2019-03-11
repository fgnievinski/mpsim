function out = diag (A)
    D = diag(cell(A));
    out = cellfun(@diag, D, 'UniformOutput',false);
    out = cell2mat(out);
end

