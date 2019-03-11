function cd = polyder2x (c)
    [nx, ny] = size(c);
    cd = zeros(nx-1, ny);
    for k=1:ny
        %temp = polyder(c(:,k));  % WRONG!
        temp = myflip(polyder(myflip(c(:,k))));
        n = numel(temp);
        cd(1:n,k) = temp;
    end
    %c, cd  % DEBUG
end

%!shared
%! rand('seed',0)
%! N = ceil(10*rand);
%! N = 4;
%! x = rand(N,1);
%! y = rand(N,1);

%!test
%! % one-dimensional case.
%! n_x = 1;  n_y = 0;
%! n_x = 2;  n_y = 0;
%! n_x = 3;  n_y = 0;
%! c = randint(-1, +1, [n_x+1, n_y+1]);
%! 
%! f  = polyval2 (c, x, y);
%! cd = polyder2x (c);
%! fd = polyval2 (cd, x, y);
%! 
%! f2  = polyval (myflip(c), x);
%! cd2 = myflip(polyder(myflip(c)));
%! fd2 = polyval (myflip(cd2), x);
%! 
%! cd3 = [];
%! fd3 = diff_func(@(x_) polyval2 (c, x_, y), x);
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
%! cd = polyder2x (c);
%! fd = polyval2 (cd, x, y);
%! 
%! fd2 = diff_func(@(x_) polyval2 (c, x_, y), x);
%! 
%! [fd, fd2, fd2-fd]  % DEBUG
%! myassert(fd2, fd, -sqrt(eps()))

