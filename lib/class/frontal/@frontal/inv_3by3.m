function A = inv_3by3 (A)
    A = frontal(frontal_inv_3by3(defrontal(A)));
end
