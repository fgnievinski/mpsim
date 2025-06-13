function answer = subsasgn (A, s, B)
    if isfrontal(A),  A = defrontal(A);  end
    if isfrontal(B),  B = defrontal(B);  end
    answer = frontal(subsasgn(A, s, B));
end

