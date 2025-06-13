function mat = mat_normal(mat, n)
    if (nargin < 2),  n = -Inf;  end
    [deg, min, sec, sig] = mat_parts(mat);

    %% Check seconds first:
    % overflowing?
    temp = rem(sec, 60);
    min = min + (sec - temp) / 60;
    sec = temp;
    % nearly overflowing?
    idx = abs(sec - 60) <= (eps(60*3600) + 10^n);
    sec(idx) = 0;
    min(idx) = min(idx) + 1;

    %% Check minutes then:
    % overflowing?
    temp = rem(min, 60);
    deg = deg + (min - temp) / 60;
    min = temp;
    % nearly overflowing:
    idx = abs(min - 60) <= eps(60*60);
    min(idx) = 0;
    deg(idx) = deg(idx) + 1;

    %%
    mat = [deg min sec sig];
end

%!test
%! mat = [...
%!     0    0   0   1
%!     0    0  60   1
%!     0   60   0   1
%!     0   60  60   1
%! ];
%! answer = [...
%!     0   0   0    1
%!     0   1   0    1
%!     1   0   0    1
%!     1   1   0    1
%! ];
%! answer2 = mat_normal (mat);
%! %answer, answer2  % DEBUG
%! myassert(answer2, answer)

%!test
%! mat = [...
%!     2    2   2   1
%!     2    2  62   1
%!     2   62   2   1
%!     2   62  62   1
%! ];
%! answer = [...
%!     2   2   2    1
%!     2   3   2    1
%!     3   2   2    1
%!     3   3   2    1
%! ];
%! answer2 = mat_normal (mat);
%! %answer, answer2  % DEBUG
%! myassert(answer2, answer)

%!test
%! d = eps(60)/10;
%! mat = [...
%!     0    0     0    1
%!     0    0  60-d    1
%!     0   60-d   0    1
%!     0   60-d  60-d  1
%! ];
%! answer = [...
%!     0   0   0    1
%!     0   1   0    1
%!     1   0   0    1
%!     1   1   0    1
%! ];
%! answer2 = mat_normal (mat);
%! %answer, answer2  % DEBUG
%! myassert(answer2, answer)

%!test
%! % d applyes only to sec
%! d = 0.1;
%! mat = [...
%!     0    0     0    1
%!     0    0    60-d  1
%!     0   60-d   0    1
%!     0   60-d  60-d  1
%! ];
%! answer = [...
%!     0   0   0    1
%!     0   1   0    1
%!     0   60-d   0    1
%!     1    1-d   0  1
%! ];
%! answer2 = mat_normal (mat, -1);
%! %answer, answer2  % DEBUG
%! myassert(answer2, answer, -eps(60))

