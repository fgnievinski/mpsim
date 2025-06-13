function X = trisolve_diag (B, Q)
    if ~isvector(Q)
        error ('trilin:trisolve_diag:badSize', ...
            'Q must be a vector.');
    end
    if length(Q) ~= size(B,1)
        error ('trilin:trisolve_diag:innerdim', ...
            'Inner dimensions must agree.');
    end
    
    temp = repmat (Q, 1, size(B, 2));
    X = B ./ temp;
end

%!error
%! lasterr('','');
%! trisolve_diag (ones(1,2), ones(2,2))

%!test
%! % trisolve_diag ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:trisolve_diag:badSize');

%!error
%! lasterr('','');
%! trisolve_diag (ones(10,1), ones(11,1))

%!test
%! % trisolve_diag ()
%! s = lasterror;
%! myassert (s.identifier, 'trilin:trisolve_diag:innerdim');

%!test
%! n = 4;
%! n2 = 5;
%! A = rand.*eye(n);
%! B = rand(n, n2);
%! Q = trifactor_diag (A);
%! X = trisolve_diag (B, Q);
%! X2 = A\B;
%! %X, X2
%! myassert (X, X2, -10*eps);

%!test
%! A = rand(1,1);
%! B = rand(1,1);
%! Q = trifactor_diag (A);
%! X = trisolve_diag (B, Q);
%! X2 = A\B;
%! %X, X2
%! myassert (X, X2, -10*eps);

