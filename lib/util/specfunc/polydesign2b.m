% partial derivatives w.r.t. coordinates:
% B is NOT independent of the coefficients.
% call polydesign2a to obtain A.
function B = polydesign2b (x, y, c, A, opt)
    if (nargin < 5),  opt = 'compact';  end
    myassert(any(strcmp(opt, {'compact', 'expanded'})));
    m = length(x);
      myassert (length(y), m);
    siz = size(c);
    n = prod(siz);
    N_x = siz(1);
    N_y = siz(2);

    if any(x == 0) || any(y == 0)
        error ('B not defined for x,y=0.');
    end
   
    p_x = (0:N_x-1);  % exponents of powers of x.
    p_y = (0:N_y-1);  % eyponents of powers of y.
    [I_x, I_y] = ndgrid(1:N_x, 1:N_y);
      % DEBUG:
      %m, n, N_x, N_y
      %size(c)
      %size(I_x), size(I_y)
      %size([I_x(:), I_y(:)])
      %size(c(I_x(:), I_y(:))')
      %size(c(sub2ind([N_x, N_y], I_x(:), I_y(:)))')
      %size(repmat(c(sub2ind([N_x, N_y], I_x(:), I_y(:)))', m, min(1,n)))
      %size(repmat(p_x(I_x(:)),m,min(1,n)))
      %size(A)
      %size(repmat(x(:),min(1,m),n))
      %%keyboard
    C = repmat(c(sub2ind([N_x, N_y], I_x(:), I_y(:)))', m, 1);
    Bx = C .* repmat(p_x(I_x(:)), m, 1) .* A ./ repmat(x(:), 1, n);
    By = C .* repmat(p_y(I_y(:)), m, 1) .* A ./ repmat(y(:), 1, n);
    Bx = sum(Bx,2);
    By = sum(By,2);
    % The version above is vectorized; below, in the test cases, 
    % there are simpler versions, beased on loops.

    switch opt
    case 'compact'
        B = [Bx, By];
    case 'expanded'
        % design matrix w.r.t observations:
        B = [spdiags(Bx, 0, m, m), spdiags(By, 0, m, m)];
    end
end

%!test
%! B = polydesign2b (rand(0,0), rand(0,0), rand(0,0), rand(0,0));
%! myassert (isempty(B))

%!shared
%! m = 10 + ceil(10*rand);
%! x = rand(m,1);
%! y = rand(m,1);
%! n_x = ceil(10*rand/2);
%! n_y = ceil(10*rand/2);
%! n = (n_x+1) * (n_y+1);
%! c = rand(n_x+1, n_y+1);

%!test
%! % simpler, slower version:
%! function B = polydesign2b2 (x, y, c, A)
%!     clear A  % we recalculate A implicitly here.
%!     m = length(x);
%!       myassert (length(y), m);
%!     siz = size(c);
%!     n = prod(siz);
%!     N_x = siz(1);
%!     N_y = siz(2);
%!     n_x = N_x - 1;
%!     n_y = N_y - 1;
%!     
%!     Bx = zeros(m,1);  By = zeros(m,1);
%!     for p_x=0:n_x, for p_y=0:n_y
%!         i_x = p_x + 1;  i_y = p_y + 1;
%!         Bx = Bx + c(i_x, i_y) * p_x * x.^(p_x-1) .* y.^ p_y;
%!         By = By + c(i_x, i_y) * p_y * x.^ p_x    .* y.^(p_y-1);
%!     end, end
%! 
%!     B = [Bx, By];
%! end
%! 
%! % another slower version:
%! function B = polydesign2b3 (x, y, c, A)
%!     m = length(x);
%!       myassert (length(y), m);
%!     siz = size(c);
%!     n = prod(siz);
%!     N_x = siz(1);
%!     N_y = siz(2);
%!     n_x = N_x - 1;
%!     n_y = N_y - 1;
%!     
%!     Bx = zeros(size(x));  By = zeros(size(y));
%!     for p_x=0:n_x, for p_y=0:n_y
%!         i_x = p_x + 1;  i_y = p_y + 1;
%!         k = sub2ind2 ([n_x+1, n_y+1], i_x, i_y);
%!         Bx = Bx + c(i_x, i_y) * p_x .* A(:,k) ./ x;
%!         By = By + c(i_x, i_y) * p_y .* A(:,k) ./ y;
%!     end, end
%! 
%!     B = [Bx, By];
%! end
%! 
%! A  = polydesign2a  (x, y, c);
%! B  = polydesign2b  (x, y, c, A);
%! B2 = polydesign2b2 (x, y, c, A);
%! B3 = polydesign2b3 (x, y, c, A);
%! 
%! % numerical derivatives:
%! temp = @(coord) polyval2 (c, coord(1:end/2), coord(end/2+1:end));
%! B4 = diff_func2 (temp, [x; y]);
%! B4 = [diag(B4(:,1:end/2)), diag(B4(:,end/2+1:end))];
%!
%! %B, B2, B3, B4
%! %max(max(abs(B - B2)))
%! %max(max(abs(B - B3)))
%! %max(max(abs(B - B4)))
%! myassert(B, B2, -10*sqrt(eps))
%! myassert(B, B3, -10*sqrt(eps))
%! myassert(B, B4, -10*sqrt(eps))

