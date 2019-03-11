% partial derivatives w.r.t. parameters:
% A is independent of the coefficients  
% (we need to know only c's size).
function A = polydesign1a (x, c)
    [d, n] = polyc2d(c);

    % powers of x (run from 0 to n-1.)
    A = repmat(x(:), 1, n);
    if isnan(d),  return;  end  % no polynomial
    A(:,1) = 1;  % power of zero.
    A = cumprod(A, 2);

    A = fliplr(A);  % polyval's convention.
end

%!test
%! %rand('seed',0)
%! m = 10 + ceil(10*rand);
%! x = rand(m,1);
%! n = ceil(10*rand/2);
%! c = rand(n+1,1);
%! 
%! % simpler, slower version:
%! function A = polydesign1a2 (x, c)
%!     m = length(x);
%!     n = length(c);
%!     A = zeros (m, n);
%!     for p=0:(n-1)
%!         A(:,p+1) = x.^p;
%!     end
%!     A = fliplr(A);  % polyval's convention.
%! end
%! 
%! % another slower version:
%! function A = polydesign1a3 (x, c)
%!     m = length(x);
%!     n = length(c);
%!     xp = zeros(m, n);
%!     xp(:,0+1) = 1;  % zero-th power goes into first column
%!     for p=1:(n-1)
%!         i=p+1;
%!         xp(:,i) = xp(:,i-1) .* x;
%!     end
%!     A = xp;
%!     A = fliplr(A);  % polyval's convention.
%! end
%! 
%! A  = polydesign1a  (x, c);
%! A2 = polydesign1a2 (x, c);
%! A3 = polydesign1a3 (x, c);
%! % numerical derivative:
%! A4 = diff_func2 (@(c_) polyval (c_, x), c(:));
%!
%! %(max(abs(A - A2)))
%! %(max(abs(A - A3)))
%! %(max(abs(A - A4)))
%! myassert(A, A2, -eps)
%! myassert(A, A3, -eps)
%! myassert(A, A4, -sqrt(eps))

