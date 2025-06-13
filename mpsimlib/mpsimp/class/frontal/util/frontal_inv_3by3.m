function C = frontal_inv_3by3 (A)
    [m,n,o] = size(A);
    if (m ~= 3) && (n ~= 3)
        error('MATLAB:frontal:inv:square', ...
        'Frontal pages must be of size 3-by-3.');
    end
    C = inv_3by3 (A);
end

