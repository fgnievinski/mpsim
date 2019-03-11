function Q = trifactor_diag (A)
    Q = diag(A);
end

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     A = rand*eye(n);
%!     A = cast(A, precision);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     Q = diag(A);
%!     Q2 = trifactor_diag (A);
%! 
%!     %temp = Q2 - Q;  max(abs(temp(:)))  % DEBUG
%!     myassert(Q2, Q, -eps(precision))
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end

