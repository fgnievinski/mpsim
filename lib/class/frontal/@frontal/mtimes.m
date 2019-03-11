function C = mtimes (A, B)
    C = frontal(frontal_mtimes(defrontal(A), defrontal(B)));
end
