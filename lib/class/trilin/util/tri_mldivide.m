function X = tri_mldivide (A, B)
    [Q, opt] = trifactor (A);
    opt.do_warn = true;  tricond (norm(A,1), Q, opt);
    X = trisolve (B, Q, opt);
end

%!test
%! x = tri_mldivide ([], []);
%! myassert (isempty(x));

%!test
%! n = 10;
%! A = gallery('minij', n);
%! b = rand(n, 1);
%! myassert (tri_mldivide(A, b), A\b, -eps);

