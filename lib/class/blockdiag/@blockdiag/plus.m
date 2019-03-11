function answer = plus (left, right)
    if isblockdiag(left) && isblockdiag(right)
        error(check_op (left, right, 'plus', 'blockdiag:plus'));
        answer = do_op (left, right, 'plus');
    %elseif isscalar(left) || isscalar(right)
    %    error('TODO')
    elseif isblockdiag(left) && ~isblockdiag(right) ...
        && issquare(left) && issquare(right) ...
        && issparse(right) && isdiag(right)
        [ms, ns] = sizes(left);
        right2 = blockdiag(diag(mat2cell(right, diag(ms), diag(ns))));
        answer = left + right2;
        %whos
    elseif isblockdiag(right) && ~isblockdiag(left) ...
        && issquare(left) && issquare(right) ...
        && issparse(left) && isdiag(left)
        answer = right + left;
    %elseif isblockdiag(left) && ~isblockdiag(right)
    %    error('TODO')
    %    %[ms, ns] = sizes(left);
    %    %right2 = mat2cell(right, ms, ns);
    %    %...
    %    %right2 = blockdiag(right2);
    %elseif ~isblockdiag(left) && isblockdiag(right)
    %    error('TODO')
    %elseif ~isblockdiag(left) && ~isblockdiag(right)
    %    error('TODO')
    else
        answer = unblockdiag(left) + unblockdiag(right);
        %error('TODO')
    end
end

%!test
%! % plus
%! warning('off', 'test:noFuncCall');

%!test
%! myassert (isempty(blockdiag() + blockdiag()));

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
%! % isblockdiag(left) && isblockdiag(right)
%! Z = unblockdiag(X) + unblockdiag(X);
%! Z2 = X + X;
%! Z3 = unblockdiag(Z2);
%! myassert(~isblockdiag(Z))
%! myassert(isblockdiag(Z2))
%! myassert(~isblockdiag(Z3))
%! %whos
%! %max(abs(Z3(:) - Z(:)))  % DEBUG
%! myassert(Z3, Z, -eps)

%!shared
%! D = {};
%! N = 1 + ceil(10*rand);
%! for i=1:N
%!     %m = ceil(10*rand);
%!     n = ceil(10*rand);
%!     D{i} = rand(n);
%! end
%! X = blockdiag(D);

%!test
%! % isblockdiag(left) && ~isblockdiag(right) ...
%! % && issquare(left) && issquare(right) ...
%! % && issparse(right) && isdiag(right)
%! Y = speye(size(X));
%! Z = unblockdiag(X) + Y;
%! Z2 = X + Y;
%! Z3 = unblockdiag(Z2);
%! myassert(issparse(Y))
%! myassert(~isblockdiag(Z))
%! myassert(isblockdiag(Z2))
%! myassert(~isblockdiag(Z3))
%! %whos
%! %max(abs(Z3(:) - Z(:)))  % DEBUG
%! myassert(Z3, Z, -eps)

%!test
%! % elseif isblockdiag(right) && ~isblockdiag(left) ...
%! % && issquare(left) && issquare(right) ...
%! % && issparse(left) && isdiag(left)
%! Y = speye(size(X));
%! Z = Y + unblockdiag(X);
%! Z2 = Y + X;
%! Z3 = unblockdiag(Z2);
%! myassert(issparse(Y))
%! myassert(~isblockdiag(Z))
%! myassert(isblockdiag(Z2))
%! myassert(~isblockdiag(Z3))
%! %whos
%! %max(abs(Z3(:) - Z(:)))  % DEBUG
%! myassert(Z3, Z, -eps)

%!test
%! warning('on', 'test:noFuncCall');
        
