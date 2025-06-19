function answer = isdiag (A)
    D = diag(cell(A))
    temp = cellfun(@isdiag, D)
    answer = all(temp);
end

