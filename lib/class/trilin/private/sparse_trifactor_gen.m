function [Q, Q2] = sparse_trifactor_gen (A)
    [Q,Q2{1},Q2{2},Q2{3}] = lu(A);
    % from doc lu: "This syntax uses UMFPACK and is significantly more time and memory efficient than the other syntaxes".
end

%!test

