function answer = tri_rcond (A)
    [Q, opt] = trifactor (A);
    opt.do_warn = false;
    answer = tricond (norm(A,1), Q, opt);
end

%!test
%! n = 10;
%! A = gallery('minij', n);
%! b = rand(n, 1);
%! myassert (tri_rcond(A), rcond(A), -eps);

