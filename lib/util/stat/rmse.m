function y = rmse (x, dim)
%NANRMSE  Root-mean-square error.
    if (nargin < 2),  dim = [];  end
    ignore_nans = false;
    y = nanrmse (x, dim, ignore_nans);
end

%!test
%! x = [5 4 3];
%! answer = sqrt(5*5+4*4+3*3) / sqrt(3);
%! myassert ( rmse(x), answer);

%!test
%! % rmse and stdev are related (NOT the same) when the sample mean is zero:
%! tol = -10*eps;
%! n = 100;
%! x = rand(n, 1);
%! x2 = x - mean(x);
%! myassert (mean(x2), 0, tol);
%! myassert ( rmse(x2), std(x2)*sqrt((n-1)/n), tol );

%!test
%! % matrix input
%! m = 1+ceil(10*rand());
%! n = 1+ceil(10*rand());
%! x = rand(m,n);
%! y = NaN(1,n);
%! for j=1:n
%!   y(j) = rmse(x(:,j));
%! end
%! y2 = rmse(x, 1);
%! %y2 - y  % DEBUG
%! myassert(y2, y, sqrt(eps()))

%!test
%! % matrix input
%! m = 1+ceil(10*rand());
%! n = 1+ceil(10*rand());
%! x = rand(m,n);
%! y = NaN(m,1);
%! for i=1:m
%!   y(i) = rmse(x(i,:));
%! end
%! y2 = rmse(x, 2);
%! %y2 - y  % DEBUG
%! myassert(y2, y, sqrt(eps()))

%!test
%! % dim takes precedence over matrix/vector:
%! m = 1+ceil(10*rand());
%! n = 1+ceil(10*rand());
%! x = rand(m,n);
%! y = NaN(m,1);
%! for i=1:m
%!   y(i) = rmse(x(i,:));
%! end
%! y2 = rmse(x, 2);
%! %y2 - y  % DEBUG
%! myassert(y2, y, sqrt(eps()))


