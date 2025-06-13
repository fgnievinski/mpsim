function Q = trifactor_tri (A, uplow)
    Q = A;
end

%!test
%! for storage = {'full', 'sparse'};  storage = storage{:};
%! for precision = {'double', 'single'}, precision = precision{:};
%! for uplow = {'upper', 'lower'}, uplow = uplow{:};
%! for i=1:10
%!     n = ceil(10*rand);
%!     A = rand*eye(n);
%!     A = cast(A, precision);
%!     A = triuplow(A, uplow);
%!     if strcmp(storage, 'sparse') && ~strcmp(precision, 'single')
%!         A = sparse(A);
%!     end
%! 
%!     Q = A;
%!     Q2 = trifactor_tri (A);
%! 
%!     %temp = Q2 - Q;  max(abs(temp(:)))  % DEBUG
%!     myassert(Q2, Q, -eps(precision))
%!     if issparse(A),  myassert(issparse(Q));  end
%! end
%! end
%! end
%! end

