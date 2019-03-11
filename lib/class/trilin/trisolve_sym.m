function varargout = trisolve_sym (varargin)
    if issparse(varargin{1}) || issparse(varargin{2})
        [varargout{1:nargout}] = sparse_trisolve_sym (varargin{:});
    else
        [varargout{1:nargout}] =   full_trisolve_sym (varargin{:});
    end
end

%!test
%! X = trisolve_sym([], [], cast([],'int8'));
%! myassert (isempty(X));

%!test
%! % symmetric indefinite matrices:
%! warning('off', 'trilin:trifacotor_sym:sparse');
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     n2 = ceil(10*rand);
%!     A = gallery(matrix_type, n) - 10*eye(n);
%!     B = rand(n, n2);
%!     A = cast(A, precision);
%!     B = cast(B, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!         B = sparse(B);
%!     end
%! 
%!     [Q, p] = trifactor_sym (A, uplow);
%!     X = trisolve_sym (B, Q, p, uplow);
%!
%!     %{precision, i, n, n2, norm(X - A\B)}  % DEBUG
%!     myassert (X, A\B, -10*eps(precision));
%!     [R, p] = chol(A);
%!     if (p == 0), error('test matrix should NOT be pos-def.');  end
%!     if issparse(A) && issparse(B),  myassert(issparse(X));  end
%! end
%! end
%! end
%! end
%! end
%! warning('on', 'trilin:trifacotor_sym:sparse');

