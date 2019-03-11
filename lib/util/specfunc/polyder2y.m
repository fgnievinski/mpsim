function cd = polyder2y (c)
    cd = transpose(polyder2x(transpose(c)));
end

%!shared
%! rand('seed',0)
%! N = ceil(10*rand);
%! N = 4;
%! x = rand(N,1);
%! y = rand(N,1);

%!test
%! % one-dimensional case.
%! n_x = 0;  n_y = 1;
%! n_x = 0;  n_y = 2;
%! n_x = 0;  n_y = 3;
%! c = randint(-1, +1, [n_x+1, n_y+1]);
%! 
%! f  = polyval2 (c, x, y);
%! cd = polyder2y (c);
%! fd = polyval2 (cd, x, y);
%! 
%! f2  = polyval (myflip(c), y);
%! cd2 = myflip(polyder(myflip(c)));
%! fd2 = polyval (myflip(cd2), y);
%! 
%! cd3 = [];
%! fd3 = diff_func(@(y_) polyval2 (c, x, y_), y);
%! 
%! %[f, f2, f2-f]
%! %c, cd, cd2, cd2(:)-cd(:)  % DEBUG
%! %[fd, fd2, fd2-fd]  % DEBUG
%! %[fd, fd3, fd3-fd]  % DEBUG
%! myassert(f2, f, -sqrt(eps()))
%! myassert(cd2(:), cd(:), -sqrt(eps()))
%! myassert(fd2, fd, -sqrt(eps()))
%! myassert(fd3, fd, -sqrt(eps()))

%!test
%! % two-dimensional case:
%! n_x = ceil(10*rand);
%! n_y = ceil(10*rand);
%! n_x = 1;  n_y = 0;
%! n_x = 2;  n_y = 0;
%! n_x = 1;  n_y = 1;
%! n_x = 2;  n_y = 2;
%! c = randint(-1, +1, [n_x+1, n_y+1]);
%! 
%! cd = polyder2y (c);
%! fd = polyval2 (cd, x, y);
%! 
%! fd2 = diff_func(@(y_) polyval2 (c, x, y_), y);
%! 
%! %[fd, fd2, fd2-fd]  % DEBUG
%! myassert(fd2, fd, -sqrt(eps()))

