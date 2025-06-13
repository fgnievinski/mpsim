% The actual code is in mtimes.c

%!test
%! % mtimes ()
%! warning('off', 'test:noFuncCall');


%!test
%! temp = packed([]) * eye(3);
%! myassert (isempty(temp));
%! myassert (~ispacked(temp));


%!error
%! lasterr('', '');
%! temp = packed(eye(3)) * single(eye(3));

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:mtimes:diffClasses');


%!error
%! lasterr('', '');
%! temp = packed(true(3)) * true(3);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:mtimes:nonFloatNotSupported');


%!error
%! lasterr('', '');
%! temp = packed(eye(3)) * zeros(3,3,3);

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:mtimes:inputsMustBe2D');


%!error
%! lasterr('', '');
%! temp = packed(eye(3)) * complex(eye(3,3));

%!test
%! s = lasterror;
%! myassert (s.identifier, 'packed:mtimes:complexNotSupported');


%!test
%! for precision = {'single', 'double'}, precision = precision {:};
%! for matrix_type = {'sym', 'tri'}, matrix_type = matrix_type {:};
%! for uplow = {'up', 'low'}, uplow = uplow {:};
%! for i=1:1
%!     k = 10;
%!     while true
%!         nl = ceil(k*rand);
%!         if (nl > 1),  break;  end
%!     end
%!     while true
%!         nr = ceil(k*rand);
%!         if (nr > 1),  break;  end
%!     end
%! 
%!     A = cast(packed(rand(nl), matrix_type, uplow), precision);
%!     A_full = full(A);
%!     B_full = cast(rand(nl, nr), precision);
%!     p = rand;
%!
%!     %{precision, matrix_type, uplow, nl, nr}  % DEBUG
%!
%!     myassert(full(A * p), A_full * p, -k*eps(precision)) 
%!     myassert(full(p * A), p * A_full, -k*eps(precision)) 
%!     myassert(A * B_full, A_full * B_full, -k*eps(precision)) 
%!     myassert((B_full.' * A.').', (B_full.' * A_full.').', -k*eps(precision))
%!     myassert(full(A * A), A_full * A_full, -k*eps(precision)) 
%!     if ~strcmp(precision, 'double'),  continue;  end
%!     B_sparse = sparse(B_full);
%!     myassert(A * B_sparse, A_full * B_sparse, -k*eps(precision)) 
%!     myassert((B_sparse.' * A.').', (B_sparse.' * A_full.').', -k*eps(precision))
%! 
%! end
%! end
%! end
%! end

%!test
%! warning('on', 'test:noFuncCall');

