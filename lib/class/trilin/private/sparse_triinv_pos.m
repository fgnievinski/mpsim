function X = sparse_triinv_pos (Q, uplow)
    switch uplow
    case 'upper'
        X = Q \ (Q.' \ speye(size(Q)));
    case 'lower'
        X = Q.' \ (Q \ speye(size(Q)));
    end
end

