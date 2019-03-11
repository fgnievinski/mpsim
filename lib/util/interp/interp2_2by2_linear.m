function z = interp2_2by2_linear (X, Y, Z, x, y)
    myassert(size(Z,1) == 2)
    myassert(size(Z,2) == 2)

    Zll = permute(Z(2,1,:),[3,2,1]);  % lower-left
    Zlr = permute(Z(2,2,:),[3,2,1]);  % lower-right
    Zul = permute(Z(1,1,:),[3,2,1]);  % upper-left
    Zur = permute(Z(1,2,:),[3,2,1]);  % upper-right
    % Please note that row indexing is flipped 
    % upside-down with respect to y coordinates.

    Xl = X(:,1);  Xr = X(:,2);
    Yl = Y(:,2);  Yu = Y(:,1);

    Zl = ( (x - Xl) .* Zlr - (x - Xr) .* Zll ) ./ (Xr - Xl);
    Zu = ( (x - Xl) .* Zur - (x - Xr) .* Zul ) ./ (Xr - Xl);
    z  = ( (y - Yl) .* Zu  - (y - Yu) .* Zl  ) ./ (Yu - Yl);
end

%!test
%! N = ceil(100*rand);
%! Z = rand(2,2,N);
%! X = rand(N,2);
%! Y = rand(N,2);
%! x = randint(X(:,1), X(:,2));
%! y = randint(Y(:,1), Y(:,2));
%! 
%! tic = cputime;
%! z = zeros(N,1);
%! for i=1:N
%!     z(i) = interp2(X(i,:), Y(i,:), Z(:,:,i), x(i), y(i), 'linear');
%! end
%! toc = cputime - tic;
%! 
%! tic = cputime;
%! z2 = interp2_2by2_linear (X, Y, Z, x, y);
%! toc2 = cputime - tic;
%! 
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -100*eps);
%! 
%! % cputime_res applies to either ta or tb individually; tol applies to ta-tb;
%! tol = 2*cputime_res() + sqrt(eps);
%! %[N, toc2, toc, tol]  % DEBUG
%! myassert (toc2 <= toc || abs(toc2-toc) <= tol);

%!test
%! % when grid is regularly and uniformly spaced, 
%! % not only within each grid but also across all grids, 
%! % then we agree with interp2_mbyn:
%! N = ceil(100*rand);
%! N = N + 100000;
%! Z = rand(2,2,N);
%! DX = rand;
%! DY = rand;
%! X = repmat(rand(N,1), 1,2) + repmat(DX.*(0:1), N, 1);
%! Y = repmat(rand(N,1), 1,2) + repmat(DY.*(0:1), N, 1);
%! x = randint(X(:,1), X(:,2));
%! y = randint(Y(:,1), Y(:,2));
%! 
%! tic = cputime;
%! z = interp2_mbyn (X, Y, Z, x, y, 2, 2);
%! toc = cputime - tic;
%! 
%! tic = cputime;
%! z2 = interp2_2by2_linear (X, Y, Z, x, y);
%! toc2 = cputime - tic;
%! 
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -100*eps);
%! 
%! % cputime_res applies to either ta or tb individually; tol applies to ta-tb;
%! tol = 2*cputime_res() + sqrt(eps);
%! %[N, toc2, toc, tol]  % DEBUG
%! myassert (toc2 <= toc || abs(toc2-toc) <= tol);

