% partial derivatives w.r.t. parameters:
% A is independent of the coefficients  
% (we need to know only c's size).
% 
% Note that input variable c is c itself 
% (or a matrix with the same size as c), 
% NOT a matrix containing the size of c; 
% e.g., c = NaN(5,5), NOT c = [5 5].
function A = polydesign2a (x, y, c)
    N = length(x);
      myassert (length(y), N);
    siz = size(c);
    siz = siz(1:2);  % (discard possibly third dimension)
    n = prod(siz);
    N_x = siz(1);
    N_y = siz(2);

    % powers of x, y:
    % (powers of x, y run from 0 to N_x-1, N_y-1.)
    xp = repmat(x(:), 1, N_x);
    yp = repmat(y(:), 1, N_y);
    xp(:,1) = 1;
    yp(:,1) = 1;
    xp = cumprod(xp, 2);
    yp = cumprod(yp, 2);

    % products of powers of x, y:
    [I_x, I_y] = ndgrid(1:N_x, 1:N_y);
    A = xp(:,I_x(:)) .* yp(:,I_y(:));
      myassert(size(A), [N,n])
end

%!test
%! A = polydesign2a (rand, rand, rand(0,0));
%! myassert (isempty(A))

%!shared
%! %rand('seed',0)
%! N = 10 + ceil(10*rand);
%! x = rand(N,1);
%! y = rand(N,1);
%! n_x = ceil(10*rand/2);
%! n_y = ceil(10*rand/2);
%! n = (n_x+1) * (n_y+1);
%! c = rand(n_x+1, n_y+1);

%!test
%! % simpler, slower version:
%! function A = polydesign2a2 (x, y, c)
%!     N = length(x);
%!       myassert (length(y), N);
%!     siz = size(c);
%!     n = prod(siz);
%!     N_x = siz(1);
%!     N_y = siz(2);
%!     n_x = N_x - 1;
%!     n_y = N_y - 1;
%!     
%!     A = zeros (N, n);
%!     for p_x=0:n_x, for p_y=0:n_y
%!         k = sub2ind2 ([n_x+1, n_y+1], p_x+1, p_y+1);
%!         A(:,k) = x.^p_x .* y.^p_y;
%!     end, end
%! end
%! 
%! % another slower version:
%! function A = polydesign2a3 (x, y, c)
%!     N = length(x);
%!       myassert (length(y), N);
%!     siz = size(c);
%!     n = prod(siz);
%!     N_x = siz(1);
%!     N_y = siz(2);
%!     
%!     % powers of x, y:
%!     xp = zeros(N, n_x+1);
%!     xp(:,0+1) = 1;  % zero-th power goes into first column
%!     for p_x=1:n_x
%!         i=p_x+1;  
%!         xp(:,i) = xp(:,i-1) .* x;
%!     end
%!     yp = zeros(N, n_y+1);
%!     yp(:,0+1) = 1;  % zero-th power goes into first column
%!     for p_y=1:n_y
%!         i=p_y+1;  
%!         yp(:,i) = yp(:,i-1) .* y;
%!     end
%!     %xp, yp  % DEBUG
%! 
%!     % products of powers of x, y:
%!     A = zeros(N, n);
%!     k = 0;
%!     for p_x=0:n_x, for p_y=0:n_y
%!         i_x = p_x + 1;  i_y = p_y + 1;
%!         k = sub2ind2 ([n_x+1, n_y+1], i_x, i_y);
%!         A(:,k) = xp(:,i_x) .* yp(:,i_y);
%!     end, end
%!     myassert (k == n);
%! end
%! 
%! A  = polydesign2a  (x, y, c);
%! A2 = polydesign2a2 (x, y, c);
%! A3 = polydesign2a3 (x, y, c);
%! 
%! % numerical derivative:
%! A4 = diff_func2 (@(c_) polyval2 (...
%!     reshape(c_, n_x+1, n_y+1), x, y), c(:));
%!
%! %max(max(abs(A - A2)))
%! %max(max(abs(A - A3)))
%! %max(max(abs(A - A4)))
%! myassert(A, A2, -eps)
%! myassert(A, A3, -eps)
%! myassert(A, A4, -sqrt(eps))

%!test
%! % coefficients typically are the same for all points, but may also be 
%! % given as a different set of values for each point.
%! c = rand(n_x+1, n_y+1, 1);
%! A1 = polydesign2a (x, y, c);
%! c = rand(n_x+1, n_y+1, N);
%! A2 = polydesign2a (x, y, c);
%! %A1, A2, A2-A1  % DEBUG
%! myassert(A1, A2, -eps)

