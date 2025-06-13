function varargout = trifactor_pos (A, uplow)
    if (nargin < 2),  uplow = [];  end
    if issparse(A)
        [varargout{1:nargout}] = sparse_trifactor_pos (A, uplow);
    else
        [varargout{1:nargout}] =   full_trifactor_pos (A, uplow);
    end
end

%!test
%! [Q, p] = trifactor_pos([], 'u');
%! myassert (isempty(Q));
%! myassert (p, 0);

%!test
%! % positive-definite matrices:
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'lehmer', 'minij', 'moler'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = round(10*rand);
%!     A = gallery(matrix_type, n) + 10*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%!     %{uplow, precision, matrix_type, i, n}  % DEBUG
%!     
%!     Q2 = chol2(A, uplow);
%!     [Q, info] = trifactor_pos (A, uplow);
%!     switch uplow
%!     case 'upper'
%!         Q = triu(Q);
%!         A2 = Q2'*Q2;
%!         A3 = Q'*Q;
%!     case 'lower'
%!         Q = tril(Q);
%!         A2 = Q2*Q2';
%!         A3 = Q*Q';
%!     end
%! 
%!     %Q2, Q
%!     %A, A2, A3
%!     %max(abs(A2(:)-A(:)))
%!     %max(abs(A3(:)-A(:)))
%!     myassert (A2, A, -100*eps(precision));
%!     myassert (Q, Q2, -100*eps(precision));
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end
%! end

%!test
%! % symmetric, not positive-definite matrices:
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for matrix_type = {'minij'}, matrix_type = matrix_type{:};
%! for i=1:10
%!     n = 10 + round(10*rand);
%!     A = gallery(matrix_type, n) + 10*eye(n);
%!     A(i,i) = -1;  % make it NOT positive-definite.
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     [Q2, info2] = chol2 (A, uplow);
%!     [Q, info] = trifactor_pos (A, uplow);
%!     if strcmp(uplow, 'upper'),  Q = triu(Q);  else,  Q = tril(Q);  end
%! 
%!     %info, info2
%!     %A, Q2, Q
%!     %max(abs(Q(:)-Q2(:)))
%!     myassert (info2, i);
%!     myassert (info,  i);
%!     myassert (Q, Q2, -100*eps(precision));
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end
%! end

