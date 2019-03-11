function X = trisolve (B, Q, opt)
    if ~isblockdiag(Q)
        error('blockdiag:trisolve:notSupported', ...
        'Factor matrix (second argument) must be of class blockdiag.');
    end

    if isblockdiag (B)
        [n_Q, m_Q] = sizes(diag(cell(Q)));
        [n_B, m_B] = sizes(diag(cell(B)));
        if ~isequal(n_B, m_Q)
            error('blockdiag:trisolve:badSize', 'Case not supported.');
        end
        B2 = diag(cell(B));
    else
        [n_Q, m_Q] = sizes(diag(cell(Q)));
        m_B = n_Q;
        B2 = mat2cell (B, m_B);
    end
    
    %B2, diag(cell(Q))  % DEBUG
    X = cellfun(@(b, q) trisolve (b, q, opt), B2, diag(cell(Q)), ...
        'UniformOutput', false);
    
    if isblockdiag (B)
        X = blockdiag(X);
    else
        X = cell2mat(X);
    end
end

%!test
%! A = blockdiag(1, 2, 3);
%! B = rand(3,1);
%! [Q, opt] = trifactor(A);
%! X = trisolve (B, Q, opt);
%! X2 = unblockdiag(A) \ B;
%! %whos  % DEBUG
%! myassert (X2, X, -eps);

%!test
%! % multiple right-hand sides.
%! m = 1 + ceil(10*rand);
%! A = blockdiag(1, 2, 3);
%! B = rand(3,m);
%! [Q, opt] = trifactor(A);
%! X = trisolve (B, Q, opt);
%! X2 = unblockdiag(A) \ B;
%! %whos  % DEBUG
%! myassert (X2, X, -eps);

%!test
%! % block-diag right-hand side:
%! A = blockdiag(1, 2, 3);
%! B = blockdiag(1, 2, 3);
%! [Q, opt] = trifactor(A);
%! X = unblockdiag(trisolve (B, Q, opt));
%! X2 = trisolve (unblockdiag(B), Q, opt);
%! X3 = unblockdiag(A) \ unblockdiag(B);
%! %X, whos  % DEBUG
%! myassert (X2, X, -eps);
%! myassert (X3, X, -eps);
%! myassert (X, diag([1 1 1]), -eps);
