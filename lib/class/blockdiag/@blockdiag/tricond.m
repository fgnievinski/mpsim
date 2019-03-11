function answer = tricond (A_norm, Q, opt)
    answer = cellfun(@(q) tricond(A_norm, q, opt), diag(cell(Q)));
    answer = min(answer);
    myassert(isscalar(answer) || isempty(answer));
end

