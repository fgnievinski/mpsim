function X = sparse_triinv_gen (Q, Q2)
    [L, U, P, Q] = deal(Q, Q2{:});
    X = Q * (U \ (L \ P));
    % see sparse_trisolve_gen, and replace B with eye(size(Q));
end

