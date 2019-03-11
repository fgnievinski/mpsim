function A = inv_2by2_symm (A)
    A = frontal(frontal_inv_2by2_symm(defrontal(A)));
end
