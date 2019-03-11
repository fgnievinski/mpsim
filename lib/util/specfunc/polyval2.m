function z = polyval2 (c, x, y, A)
    if (nargin < 4),  A = [];  end
    myassert (isvector(x) && isvector(y));
    myassert (length(x), length(y));
    siz = size(x);
    num_pts = prod(siz);
    x = x(:);  y = y(:);

    if isempty(A),  A = polydesign2a (x, y, c);  end

    switch size(c,3)
    case 1
        P = repmat(c(:).', size(A,1), 1);
    case num_pts
        %P = reshape(c, num_pts, [], 1);  % WRONG!
        P = defrontal_pt(frontal_reshape(c, 1, []));
    otherwise
        error('matlab:polyval2:badSize', ...
            ['Coefficient matrix "c" should have size(c,3) equal to one or '...
            'equal to the number of points.']);
    end
    z = sum(P.*A, 2);
    z = reshape(z, siz);
end

%!shared
%! N = ceil(10*rand);
%! x = rand(N,1);
%! y = rand(N,1);
 
%!test
%! n_x = 0;
%! n_y = 0;
%! c = ones(n_x+1, n_y+1);
%! 
%! z = polyval2 (c, x, y);
%! myassert (z, ones(N, 1));

%!test
%! n_x = 1;
%! n_y = 0;
%! c = ones(n_x+1, n_y+1);
%! 
%! z = polyval2 (c, x, y);
%! myassert (z, ones(N, 1) + x);

%!test
%! n_x = 0;
%! n_y = 1;
%! c = ones(n_x+1, n_y+1);
%! 
%! z = polyval2 (c, x, y);
%! myassert (z, ones(N, 1) + y);

%!test
%! n_x = 1;
%! n_y = 1;
%! c = ones(n_x+1, n_y+1);
%! 
%! z_answer = polyval2 (c, x, y);
%! z = ones(N, 1) + x + y + x.*y;
%! %z_answer - z  % DEBUG
%! myassert (z_answer, z, -100.*eps);

%!test
%! % simpler, slower version
%! function z = polyval2b (c, x, y, A)
%!     if (nargin < 4),  A = [];  end
%!     myassert (isvector(x) && isvector(y));
%!     myassert (length(x), length(y));
%!     siz = size(x);
%!     x = x(:);  y = y(:);
%! 
%!     n_x = size(c, 1) - 1;
%!     n_y = size(c, 2) - 1;
%! 
%!     if isempty(A),  A = polydesign2a (x, y, c);  end
%!     z = zeros(size(x));
%!     for p_x=0:n_x, for p_y=0:n_y
%!         i_x = p_x + 1;  i_y = p_y + 1;
%!         k = sub2ind2 ([n_x+1, n_y+1], i_x, i_y);
%!         z = z + c(i_x, i_y) .* A(:,k);
%!     end, end
%! 
%!     z = reshape (z, siz);
%! end
%! 
%! n_x = ceil(10*rand);
%! n_y = ceil(10*rand);
%! c = rand(n_x+1, n_y+1);
%! 
%! A = polydesign2a (x, y, c);
%! z_answer  = polyval2  (c, x, y, A);
%! z_answer2 = polyval2b (c, x, y, A);
%! %z_answer2 - z_answer  % DEBUG
%! myassert(z_answer, z_answer2, -100*eps)

%!test
%! % coefficients typically are the same for all points, but may also be 
%! % given different set of values for each point.
%! n_x = ceil(10*rand);
%! n_y = ceil(10*rand);
%! c = rand(n_x+1, n_y+1, N);
%! z_answer = NaN(N,1);
%! for k=1:N
%!     z_answer(k) = polyval2 (c(:,:,k), x(k), y(k));
%! end
%! z_answer2 = polyval2 (c, x, y);
%! %z_answer2 - z_answer  % DEBUG
%! myassert(z_answer, z_answer2, -100*eps)

