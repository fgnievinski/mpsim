function C = times (A, B)
    myassert(size(A), size(B));
    if (isblockdiag(A) && isblockdiag(B))
        myassert(sizes(A), sizes(B));
        C = cellfun(@times, diag(cell(A)), diag(cell(B)), ...
            'UniformOutput',false);
        C = blockdiag(C);
    elseif (isblockdiag(A) && ~isblockdiag(B))
        A2 = diag(cell(A));
        [m_A, n_A] = sizes(A2);
        m_B = m_A;
        n_B = n_A;
        B2 = diag(mat2cell(B, m_B, n_B));
        % need not to multiply off-diagonal matrices, because they are zero.
        C = cellfun(@(a, b) a .* b, A2(:), B2(:), 'UniformOutput',false);
        C = blockdiag(C{:});
    else
        error('blockdiag:times:notSupported', 'Case not supported.');
    end
end

