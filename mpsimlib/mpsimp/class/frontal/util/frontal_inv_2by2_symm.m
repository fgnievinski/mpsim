function C = frontal_inv_2by2_symm (A)
    [m,n,o] = size(A);
    if (m ~= 2) && (n ~= 2)
        error('MATLAB:frontal:inv:square', ...
        'Frontal pages must be of size 2-by-2.');
    end
    C = inv_2by2_symm (A);
end

