function x = mldivide (A, b)
    x = tri_mldivide (A, b);
end

%!test
%! % mldivide ()
%! while true
%!     n = round (10*rand);
%!     if (n > 2),  break;  end
%! end
%! A = packed(gallery('minij', n), 'sym');
%! b = rand(n, 1);
%! x1 = A \ b;
%! R = chol(A);
%! x2 = trisolve (b, R, 'positive-definite');
%! %x3 = R \ (R' \ A);
%! myassert (x1, x2, -100*eps);

