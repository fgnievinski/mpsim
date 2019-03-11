function varargout = trisolve_tri (varargin)
    if issparse(varargin{1}) || issparse(varargin{2})
        [varargout{1:nargout}] = sparse_trisolve_tri (varargin{:});
    else
        [varargout{1:nargout}] =   full_trisolve_tri (varargin{:});
    end
end

%!test
%! X = trisolve_tri([], [], 'u');
%! myassert (isempty(X));

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for trans = {'nothing', 'transpose'}, trans = trans{:};
%! for i=1:10
%!     n  = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     A = rand(n)+10*eye(n);
%!     B = rand(n, n2);
%!     A = cast(A, precision);
%!     B = cast(B, precision);
%!     A = triuplow(A, uplow);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!         B = sparse(B);
%!     end
%!     %disp({precision, uplow, i, n, n2})  % DEBUG
%! 
%!     Q = trifactor_tri (A, uplow);
%!     X = trisolve_tri (B, Q, uplow, trans);
%!     if (trans(1) == 't')
%!         %disp('hw!')  % DEBUG
%!         X2 = A'\B;
%!     else
%!         X2 = A\B;
%!     end
%! 
%!     %X - X2  % DEBUG
%!     myassert (X, X2, -10*eps(precision));
%!     if issparse(A) && issparse(B),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end

