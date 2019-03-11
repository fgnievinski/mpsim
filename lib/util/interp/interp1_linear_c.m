% This is not the actual function interp1_linear_c(), 
% it's just a test suite for that function,
% which is implemented in C-MEX.

%!test
%! Z = [1 1];
%! X = [1 2];
%! x = 1; 
%! 
%! z_correct = 1;
%! z_correct2 = interp1(X, Z, x, '*linear', NaN);
%! z = interp1_linear_c (X, Z, x);
%! %pause

%!test
%! Z = 1:4;
%! X = 1:4;
%! x = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
%! z_correct = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
%! z_correct2 = interp1(X, Z, x, '*linear', NaN);
%!
%! z = interp1_linear_c (X, Z, x);
%! 
%! %z, z_correct, z_correct2  % DEBUG
%! myassert (isequaln(z, z_correct));
%! myassert (isequaln(z, z_correct2));

%!test
%! % linearly varying observations:
%! N = 10; %1000 * ceil(100*rand)
%! n = 4;
%! Z = rand(1, n);
%! X = ceil(10*rand) + (0:n-1) * rand;
%! x = randint(X(1), X(end), 1, N);
%! 
%! z_correct2 = interp1(X, Z, x, '*linear', NaN);
%!
%! z = interp1_linear_c (X, Z, x);
%! 
%! %[x', z_correct2', z', z' - z_correct2']  % DEBUG
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! % randomly varying observations:
%! N = 10; %1000 * ceil(100*rand)
%! n = 4;
%! Z = rand(1, n);
%! X = ceil(10*rand) + (0:n-1) * rand;
%! x = randint(X(1), X(end), 1, N);
%! z_correct2 = interp1(X, Z, x, '*linear', NaN);
%!
%! z = interp1_linear_c (X, Z, x);
%! 
%! %[x', z_correct2', z', z' - z_correct2']  % DEBUG
%! myassert(~any(isnan(z_correct2)))
%! myassert(~any(isnan(z)))
%! myassert(all( abs(z - z_correct2) < 1000*eps ));

%!test
%! % extrapolation within randomly varying observations:
%! N = 10; %1000 * ceil(100*rand)
%! n = 4;
%! Z = rand(1, n);
%! X = ceil(10*rand) + (0:n-1) * rand;
%! x = randint(0, X(1), 1, N);
%! z_correct2 = interp1(X, Z, x, '*linear', NaN);
%!
%! z = interp1_linear_c (X, Z, x);
%! 
%! %[x', z_correct2', z', z' - z_correct2']  % DEBUG
%! myassert(all(isnan(z_correct2)))
%! myassert(all(isnan(z)))

%!test
%! % test case that brought bug into light;
%! % it'd only be triggered if repeated several times, though.
%! % sometimes only if copying & pasting in the matlab prompt.
%! prof_h = [...
%!      2
%!      3
%!      4
%! ];
%! prof_p = [...
%!     20
%!     10
%!      0
%! ];
%! h = 1.5;
%! %N = 100000;
%! %h = repmat(h, 1, N);
%! opt.offset = 0;
%! 
%! p1 = interp1 (prof_h, prof_p, h(:), 'linear');
%! p2 = interp1_linear_c (prof_h.', prof_p.', h(:));
%! %disp([p1, p2])  % DEBUG
%! assert(isnan(p1))
%! assert(isnan(p2))
