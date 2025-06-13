function x = tricond_diag (A_norm, Q)
    x = 1;
    x = cast(x, class(Q));
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
%!     Q = trifactor_diag (A);
%!     x = tricond_diag(norm(A,1), Q);
%!     if issparse(A)
%!         x2 = 1./condest(A);
%!     else
%!         x2 = rcond(A);
%!     end
%! 
%!     %x, x2  % DEBUG
%!     myassert(x, x2, -10*eps(precision));
%! end
%! end
%! end

