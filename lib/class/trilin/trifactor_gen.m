function varargout = trifactor_gen (varargin)
    if issparse(varargin{1})
        [varargout{1:nargout}] = sparse_trifactor_gen (varargin{:});
    else
        [varargout{1:nargout}] =   full_trifactor_gen (varargin{:});
    end
end

%!test
%! [Q, p] = trifactor_gen([]);
%! myassert (isempty(Q));
%! myassert (isempty(p));

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     m = ceil(10*rand);
%!     A = rand(m,n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%!     %{storage, precision, i, m, n}  % DEBUG
%!     %pause  % DEBUG
%! 
%!     [Q, Q2] = trifactor_gen (A);
%!     if issparse(A)
%!         [L2, U2, P2, QQ2] = lu(A);
%!         myassert(issparse(Q))
%!         myassert(Q, L2)
%!         myassert(Q2{1}, U2)
%!         myassert(Q2{2}, P2)
%!         myassert(Q2{3}, QQ2)
%!     else
%!         [L2, U2, P2] = lu (A);
%!         [L, U, P] = full_trisolve_gen_aux (Q, Q2);
%!         
%!         myassert (size(Q), [m, n]);
%!         myassert (L2, L);
%!         myassert (U2, U);
%!         myassert (P2, P);
%!         
%!         A2 = inv(P) *L *U;
%!         A3 = inv(P2)*L2*U2;
%!         myassert (A3, A2);
%!         myassert (A2, A, -10*eps(precision));
%!     end
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end

