function A = subsref (A, s)
    %s  % DEBUG
    A.data = subsref(A.data, s);
    %A = frontal(subsref(defrontal(A), s));
end

