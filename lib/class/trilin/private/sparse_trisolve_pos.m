function X = sparse_trisolve_pos (B, Q, uplow)
    switch uplow
    case 'upper'
        X = Q \ (Q.' \ B);
    case 'lower'
        X = Q.' \ (Q \ B);
    end
end

