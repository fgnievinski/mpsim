function C = mrdivide (A, B)
    C = frontal(frontal_mtimes(defrontal(A), 1./defrontal(B)));
end
