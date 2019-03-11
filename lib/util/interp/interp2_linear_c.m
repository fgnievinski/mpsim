% This is not the actual function interp2_linear_c(), 
% it's just a test suite for that function,
% which is implemented in C-MEX.

%!test
%! Z = [1     1;  1     1];
%! X = [1 2];
%! Y = [1 2];
%! x = 1; 
%! y = 1;
%! 
%! z_correct = 1;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%! z = interp2_linear_c (X, Y, Z, x, y);
%! %pause

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
%! y = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5];
%! z_correct = [1 2 3 4 2 3 4 5 3 4 5 6 4 5 6 7 5 6 7 8];
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (isequaln(z, z_correct));
%! myassert (isequaln(z, z_correct2));

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4] + 0.5;
%! y = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5];
%! z_correct = [1.5 2.5 3.5 NaN 2.5 3.5 4.5 NaN 3.5 4.5 5.5 NaN 4.5 5.5 6.5 NaN 5.5 6.5 7.5 NaN];
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (isequaln(z, z_correct));
%! myassert (isequaln(z, z_correct2));

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
%! y = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5] + 0.5;
%! z_correct = [1.5 2.5 3.5 4.5 2.5 3.5 4.5 5.5 3.5 4.5 5.5 6.5 4.5 5.5 6.5 7.5 NaN NaN NaN NaN];
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (isequaln(z, z_correct));
%! myassert (isequaln(z, z_correct2));

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = [1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4 1 2 3 4];
%! y = rand(1, length(x)) * 5;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! y = [1 1 1 1 2 2 2 2 3 3 3 3 4 4 4 4 5 5 5 5];
%! x = rand(1, length(y)) * 4;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! Z = [...
%!     1 2 3 4; 
%!     2 3 4 5; 
%!     3 4 5 6; 
%!     4 5 6 7;
%!     5 6 7 8;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = rand(1, 10) * 4;
%! y = rand(1, 10) * 5;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! Z = rand(5, 4);
%! X = 1:4;
%! Y = 1:5;
%! x = rand(1, 10) * 4;
%! y = rand(1, 10) * 5;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! n = 4;  m = 5;
%! Z = rand(4, 5);
%! X = 1:m;
%! Y = 1:n;
%! x = rand(10, 1) * m;
%! y = rand(10, 1) * n;
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%! 
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

%!test
%! Z = [...
%!     0.6969    0.3268    0.7144    0.5352 ;
%!     0.3969    0.3450    0.7264    0.7680 ;
%!     0.9829    0.8036    0.1060    0.6497 ;
%!     0.5220    0.9527    0.5779    0.1853 ;
%!     0.3069    0.3791    0.8896    0.6122 ;
%! ];
%! X = 1:4;
%! Y = 1:5;
%! x = 1;
%! y = 1.5;
%! 
%! z_correct2 = interp2(X, Y, Z, x, y, '*linear', NaN);
%!
%! z = interp2_linear_c (X, Y, Z, x, y);
%!
%! myassert (all( isnan(z_correct2) | abs(z - z_correct2) < 1000*eps ));

