function [Q, Q2] = sparse_trifactor_sym (A, uplow)
    warning('trilin:trifacotor_sym:sparse', ...
        'Symmetry ignored for sparse input -- employing general algorithm.');
    [Q, Q2] = sparse_trifactor_gen (A);    
end

