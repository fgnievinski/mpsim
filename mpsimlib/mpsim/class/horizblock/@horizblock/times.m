function C = times (A, B)
    % let @sparse do the error checking:
    A2 = sparse(size(A,1), size(A,2));
    B2 = sparse(size(B,1), size(B,2));
    try
        A2 .* B2;
    catch
        e = lasterror;
        e.identifier = strrep (e.identifier, 'MATLAB:', ...
            'horizblock:times:');
        rethrow(e);
    end
    clear A2 B2
    if ~(ishorizblock(A) && ~ishorizblock(B))
        error('horizblock:times:notSupported', 'Case not supported.');
    end
    myassert(size(A), size(B));
    
    A2 = cell(A);
    [m_A, n_A] = sizes(A2);
    n_B = n_A;
    B2 = mat2cell (B, size(B,1), n_B);
    C = cell(1, length(n_B));
    C(:) = cellfun(@(a, b) a .* b, A2(:), B2(:), 'UniformOutput',false);
    C = horizblock(C{:});
end

