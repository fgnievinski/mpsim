function X = sparse_trisolve_gen (B, Q, Q2)
    [L, U, P, Q] = deal(Q, Q2{:});
    %length(unique(diff(diag(Q))))  % DEBGU
    X = Q * (U \ (L \ (P * B)));
    % see, e.g., p.11 of the UMFPACK User's Manual,
    % <http://www.cise.ufl.edu/research/sparse/umfpack/current/UMFPACK/Doc/UserGuide.pdf>
end

