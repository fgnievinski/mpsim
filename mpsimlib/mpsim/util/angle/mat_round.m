function mat = mat_round(mat, n)
    if (nargin < 2),  n = -2;  end
    [deg, min, sec, sig] = mat_parts(mat);
    sec = roundn(sec, n);
    mat = mat_normal([deg min sec sig], n);
end

%!test
%! mat = [...
%!     0   0       58.99  1 
%!     0   0       59.99  1 
%!     0   58.99   0      1 
%!     0   59.99   0      1 
%!     0   58.99   59.99  1 
%!     0   59.99   59.99  1 
%! ];
%! answer = [...
%!     0   0       59.00  1
%!     0   1       0      1
%!     0   58.99   0      1
%!     0   59.99   0      1
%!     0   59.99   0      1
%!     1    0.99   0      1
%! ];
%! answer2 = mat_round(mat, -1);
%! %answer2, answer  % DEBUG
%! %answer2 - answer  % DEBUG
%! myassert (answer2, answer, -eps(60));

%!test
%! answer = mat_round([0 60 0 1], 0);
%! myassert(answer, [1 0 0 1]);

