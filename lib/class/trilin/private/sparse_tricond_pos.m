function X = sparse_tricond_tri (A_norm, Q, uplow)
    switch uplow
    case 'upper'
        Q = Q.' * Q;
        A = Q;
    case 'lower'
        Q = Q * Q.';
        A = Q;
    end
    X = 1./condest(A);
    % I wish there was a function to calculate the condition number 
    % from the Cholesky factorization.
end

