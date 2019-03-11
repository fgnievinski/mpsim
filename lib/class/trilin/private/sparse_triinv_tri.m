function X = sparse_triinv_tri (Q, uplow)
    X = Q \ speye(size(Q));
end

