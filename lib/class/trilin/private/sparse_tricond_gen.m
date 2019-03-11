function x = sparse_tricond_gen (A_norm, Q, Q2)
    [L, U, P, Q] = deal(Q, Q2{:});
    A = Q * P \ (L * U);
    x = 1./condest(A);
    % I wish there was a function to calculate the condition number 
    % from the LU factorization.
end

