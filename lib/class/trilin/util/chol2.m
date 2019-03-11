function varargout = chol2(varargin)
    s_old = lasterror;
    try
        [varargout{1:nargout}] = chol(varargin{:});
        return;
    catch
        s = lasterror;
        if ~strcmp(s.identifier, 'MATLAB:maxrhs') || (nargin ~= 2)
            rethrow(s);
        end
        A = varargin{1};
        uplow = varargin{2};
        if strcmp(uplow, 'upper')
            [varargout{1:nargout}] = chol(A);
            lasterror(s_old);
            return;
        elseif strcmp(uplow, 'lower')
            [varargout{1:nargout}] = chol(A);
            varargout{1} = transpose(varargout{1});
            lasterror(s_old);
            return;
        else
            error('MATLAB:chol:inputType', ...
                'Shape flag must be ''upper'' or ''lower''.')
        end
    end
    % If we run 
    %     builtin('chol', A, varargin{:})
    % instead of
    %     chol(A, varargin{:})
    % then we get 'MATLAB:UndefinedFunction' error with 
    % user-defined classes.    
end

%!shared
%! n = ceil(10*rand);
%! A = gallery('minij', n);  % pos. def. matrix
%! R = builtin('chol', A);
%! L = transpose(builtin('chol', A));

%!test
%! L2 = chol2(A, 'lower');
%! %L2, L  % DEBUG
%! myassert(L2, L)

%!test
%! R2 = chol2(A, 'upper');
%! myassert(R2, R);

%!test
%! R2 = chol2(A);
%! myassert(R2, R);

%!test
%! B = A; B(1,1) = -1;  % makes it NOT pos. def.
%! [R, p] = builtin('chol', B);
%!   myassert(p, 1);
%! [R2, p] = chol2(B);
%!   myassert(p, 1);
%! myassert(R2, R)

%!test
%! R = chol2([]);
%! myassert(isempty(R))

%!test
%! % chol2()
%! s = lasterror('reset');

%!error
%! chol2(A, 'WRONG');

%!test
%! % chol2()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'MATLAB:chol:inputType'))
%! lasterror(s);

%!test
%! % chol2()
%! s = lasterror('reset');

%!error
%! chol2();

%!test
%! % chol2()
%! s = lasterror;
%! myassert(strcmp(s.identifier, 'MATLAB:minrhs'))
%! lasterror(s)
