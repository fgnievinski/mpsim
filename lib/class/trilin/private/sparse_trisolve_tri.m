function X = sparse_trisolve_tri (B, Q, uplow, trans)
    if (trans(1) == 't')
        X = Q' \ B;
    else
        X = Q \ B;
    end
end

