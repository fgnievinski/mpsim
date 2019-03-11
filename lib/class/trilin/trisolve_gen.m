function varargout = trisolve_gen (varargin)
    if issparse(varargin{1}) || issparse(varargin{2})
        [varargout{1:nargout}] = sparse_trisolve_gen (varargin{:});
    else
        [varargout{1:nargout}] =   full_trisolve_gen (varargin{:});
    end
end

%!test
%! X = trisolve_gen([], [], cast([],'int8'));
%! myassert (isempty(X));

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     m = ceil(10*rand);
%!     A = rand(n) + 10*eye(n);
%!     B = rand(n,m);
%!     A = cast(A, precision);
%!     B = cast(B, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!         B = sparse(B);
%!     end
%!     %disp({storage, precision, i, n, m})  % DEBUG
%! 
%!     [Q, Q2] = trifactor_gen (A);
%!     X = trisolve_gen (B, Q, Q2);
%!     X2 = A \ B;
%! 
%!     %temp = X - X2;  max(abs(temp(:)))  % DEBUG
%!     myassert (X, X2, -100*eps(precision));
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end

