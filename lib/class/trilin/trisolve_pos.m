function varargout = trisolve_pos (varargin)
    if issparse(varargin{1}) || issparse(varargin{2})
        [varargout{1:nargout}] = sparse_trisolve_pos (varargin{:});
    else
        [varargout{1:nargout}] =   full_trisolve_pos (varargin{:});
    end
end

%!test
%! X = trisolve_pos([], []);
%! myassert (isempty(X));

%!test
%! % positive-definite matrices:
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     %{uplow, precision, matrix_type, i, n, n2}  % DEBUG
%!     A = gallery(matrix_type, n) + 10*eye(n);
%!     B = rand(n, n2);
%!     A = cast(A, precision);
%!     B = cast(B, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!         B = sparse(B);
%!     end
%! 
%!     [Q, info] = trifactor_pos (A, uplow);
%!     X = trisolve_pos (B, Q, uplow);
%! 
%!     myassert (X, A\B, -eps(precision));
%!     switch uplow
%!     case 'upper'
%!         temp = triu(Q);
%!         myassert (X, temp \ (temp' \ B), -10*eps(precision));
%!     case 'lower'
%!         temp = tril(Q);
%!         myassert (X, temp' \ (temp \ B), -10*eps(precision));
%!     end
%!     %if issparse(A),  myassert(issparse(X));  end
%!     if issparse(A) && issparse(B),  myassert(issparse(X));  end
%! end
%! end
%! end
%! end
%! end

