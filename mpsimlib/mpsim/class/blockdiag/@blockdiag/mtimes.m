function answer = mtimes (A, B)
    if ( ndims(A) > 2 || ndims(B) > 2 )
        error ('blockdiag:mtimes:inputsMustBe2D', ...
            'Input arguments must be 2-D.');
    end
    if ( size(A, 2) ~= size(B, 1) )
        error ('blockdiag:mtimes:innerdim', ...
            'Inner dimensions must agree.');
    end

    if (isblockdiag(A) && isblockdiag(B))
        [n_A, m_A] = sizes(diag(cell(A)));
        [n_B, m_B] = sizes(diag(cell(B)));
        if ~isequal(n_B, m_A)
            error('blockdiag:mtimes:badSize', 'Case not supported.');
        end
        answer = cellfun(@mtimes, diag(cell(A)), diag(cell(B)), ...
            'UniformOutput',false);
        answer = blockdiag(answer);
        return;
    elseif (isblockdiag(A) && ~isblockdiag(B))
        A2 = diag(cell(A));
        [m_A, n_A] = sizes(A);
        m_B = diag(n_A);
        B2 = mat2cell (B, m_B, size(B,2));
        answer = cell(length(m_B), 1);
    elseif (~isblockdiag(A) && isblockdiag(B))
        [m_B, n_B] = sizes(B);
        n_A = diag(m_B);
        A2 = mat2cell (A, size(A,1), n_A);
        B2 = diag(cell(B));
        answer = cell(1, length(n_A));
    else
        %error ('blockdiag:mtimes:impossibleCase', ...
        %    'Unexpected case reached.');
        answer = A * B;
        return;
    end
    %A2, B2  % DEBUG
    answer(:) = cellfun(@(a, b) a * b, A2(:), B2(:), 'UniformOutput',false);
    answer = cell2mat(answer);
end

%!shared
%! D = {};
%! N = 1 + ceil(10*rand);
%! for i=1:N
%!     m = ceil(10*rand);
%!     n = ceil(10*rand);
%!     D{i} = rand(m,n);
%! end
%! X = blockdiag(D);

%!test
%! % (isblockdiag(A) && ~isblockdiag(B))
%! % mtimes()
%! Y = rand(size(X,2), ceil(10*rand));
%! Z = unblockdiag(X) * Y;
%! Z2 = X * Y;
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);

%!test
%! % (~isblockdiag(A) && isblockdiag(B))
%! % mtimes()
%! Y = rand(ceil(10*rand), size(X,1));
%! Z = Y * unblockdiag(X);
%! Z2 = Y * X;
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);

%!test
%! % mtimes()
%! Y = rand(20, 3*67);
%! temp = rand(67, 67);  X = blockdiag(temp, temp, temp);
%! Z = Y * unblockdiag(X);
%! Z2 = Y * X;
%! %max(abs(Z2(:) - Z(:)))
%! %if any( abs(Z2(:) - Z(:)) > 100*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -100*eps);

%!test
%! % (isblockdiag(A) && isblockdiag(B))
%! % mtimes()
%! Z = unblockdiag(X) * unblockdiag(X');
%! Z2 = unblockdiag(X * X');
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);
