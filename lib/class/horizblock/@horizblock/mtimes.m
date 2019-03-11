function C = mtimes (A, B)
    if ( ndims(A) > 2 || ndims(B) > 2 )
        error ('horizblock:mtimes:inputsMustBe2D', ...
            'Input arguments must be 2-D.');
    end
    if ( size(A, 2) ~= size(B, 1) )
        error ('horizblock:mtimes:innerdim', ...
            'Inner dimensions must agree.');
    end

    if ~(ishorizblock(A) && ~ishorizblock(B))
        error('horizblock:mtimes:badSize', 'Case not supported.');
    end 
    
    A2 = cell(A);
    [m_A, n_A] = sizes(A2);
    m_B = n_A;
    B2 = mat2cell (B, m_B, size(B,2));
    %A2, B2  % DEBUG
    C = cell(1, length(n_A));
    C(:) = cellfun(@(a, b) a * b, A2(:), B2(:), 'UniformOutput',false);
    C = plusm(C{:});
end

function C = plusm (varargin)
    switch nargin
    case 0
        C = [];
    case 1
        C = varargin{1};
    otherwise
        C = varargin{1} + plusm(varargin{2:end});
    end
end

%!shared
%! D = {};
%! N = 1 + ceil(10*rand);
%! for i=1:N
%!     m = ceil(10*rand);
%!     n = ceil(10*rand);
%!     D{i} = rand(m,n);
%! end
%! X = horizblock(D);

%!test
%! % (ishorizblock(A) && ~ishorizblock(B))
%! % mtimes()
%! Y = rand(size(X,2), ceil(10*rand));
%! Z = full(X) * Y;
%! Z2 = X * Y;
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);

%!test
%! % (~ishorizblock(A) && ishorizblock(B))
%! % mtimes()
%! Y = rand(ceil(10*rand), size(X,1));
%! Z = Y * full(X);
%! Z2 = Y * X;
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);

%!test
%! % mtimes()
%! Y = rand(20, 3*67);
%! temp = rand(67, 67);  X = horizblock(temp, temp, temp);
%! Z = Y * full(X);
%! Z2 = Y * X;
%! %max(abs(Z2(:) - Z(:)))
%! %if any( abs(Z2(:) - Z(:)) > 100*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -100*eps);

%!test
%! % (ishorizblock(A) && ishorizblock(B))
%! % mtimes()
%! Z = full(X) * full(X');
%! Z2 = full(X * X');
%! %if any( abs(Z2(:) - Z(:)) > 10*eps ),  keyboard;  end  % DEBUG
%! myassert(Z2, Z, -10*eps);
