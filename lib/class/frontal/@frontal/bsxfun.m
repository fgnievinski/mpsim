function C = bsxfun (f, A, B)
    C = frontal(bsxfun(f, defrontal(A), defrontal(B)));
end
