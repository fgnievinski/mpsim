function z = interp2_mbyn (X, Y, Z, x, y, m, n)
    %whos  % DEBUG
    %% each point has its own m-by-n local grid:
    [m2,n2,num_pts] = size(Z);
    myassert(m2 == m);
    myassert(n2 == n);
    myassert(size(x), [num_pts,1]);
    myassert(size(y), [num_pts,1]);
    myassert(size(X), [num_pts,n]);
    myassert(size(Y), [num_pts,m]);

    %% no extrapolation:
    myassert( (X(:,1) <= x & x <= X(:,n)) | (X(:,n) <= x & x <= X(:,1)))
    myassert( (Y(:,1) <= y & y <= Y(:,m)) | (Y(:,m) <= y & y <= Y(:,1)))

    %% relative (rather than absolute) and normalized coordinates 
    %% yield a better numerical conditioning of the 
    %% polynomial design matrix (AKA Vandermonde matrix):
    X_min = X(:,1);
    Y_min = Y(:,1);
    RX = X - repmat(X_min, 1,n);
    RY = Y - repmat(Y_min, 1,m);
    rx = x - X_min;
    ry = y - Y_min;
    DX = diff(RX,1,2);
    DY = diff(RY,1,2);
    DXm = median(DX, 2);
    DYm = median(DY, 2);
    RX = RX ./ repmat(DXm, 1,n);
    RY = RY ./ repmat(DYm, 1,m);
    rx = rx ./ DXm;
    ry = ry ./ DYm;
    
    %% absolute coordinates of each n-by-n local grid might be different 
    %% for different points, but relative coordinates are the same for 
    %% different points, since the grid is regularly and uniformly spaced, 
    %% not only within each grid but also across all grids:
    RX1 = RX(1,:);
    RY1 = RY(1,:);
    myassert(RX, repmat(RX1, num_pts,1), -sqrt(eps));
    myassert(RY, repmat(RY1, num_pts,1), -sqrt(eps));

    %% get Vandermonde matrix;
    % since relative coordinates are all the same, we can calculate it 
    % only for the first point then copy it for all other points:
    [RX1_grid, RY1_grid] = meshgrid(RX1, RY1);
    A1 = polydesign2a (RX1_grid(:), RY1_grid(:), NaN(n,m));
    %A1 = polydesign2a (RX1_grid(:), RY1_grid(:), NaN(m,n));  % WRONG!
    %whos A1  % DEBUG
    %A = repmat(A, [1,1,num_pts]);
    % usually we'd solve the linear system factorizing the matrix then 
    % solving two triangular systems via back substitution. here, though,  
    % we're going to obtain the inverse explicitly then pre-multiply 
    % it by the observations; this is allowed because the system is well 
    % conditioned (since we don't use very high degree polynomials); and 
    % this is desired because we can re-use the same inverse for all points!
    % (coefficient values will be different for different points, of course).
    A1_inv = inv(A1);
    %A_inv = repmat(A1_inv, [1,1,num_pts]);
    %clear A1_inv A1

    %% fit coefficients based on coordinates:
    % reshape observations, from m-by-n matrix to m*n-by-1 vector, for each pt:
    Z_col = frontal_reshape(Z, [m*n,1]);
    % pre-multiplication by inverse matrix:
    c_col = frontal_mtimes(A1_inv, Z_col);  % FASTER
    %c_col = frontal_mtimes(A_inv, Z_col);  % SLOWER
    % notice that this is an exact fit, not least squares, since the 
    % number of parameters equals the number of observations.
    % reshape coefficients, from 16-by-1 vector to m-by-n matrix, for each pt:
    c = frontal_reshape(c_col, [n,m]);
    %c = frontal_reshape(c_col, [m,n]);  % WRONG!

    %% finally, evaluate polynomial at interpolation points:
    z = polyval2 (c, rx, ry);
end

%!shared
%! function [z, toc, z2, toc2] = doit (m, n, method)
%!     N = 10 + ceil(100*rand);
%!     Z = rand(m,n,N);
%!     RX = rand;
%!     RY = rand;
%!     X = repmat(rand(N,1), 1,n) + repmat(RX.*(0:n-1), N, 1);
%!     Y = repmat(rand(N,1), 1,m) + repmat(RY.*(0:m-1), N, 1);
%!     x = randint(X(:,1), X(:,n));
%!     y = randint(Y(:,1), Y(:,m));
%!     
%!     tic = cputime;
%!     z = interp2_mbyn (X, Y, Z, x, y, m, n);
%!     toc = cputime - tic;
%!     
%!     tic = cputime;
%!     z2 = zeros(N,1);
%!     for i=1:N
%!         z2(i) = interp2(X(i,:), Y(i,:), Z(:,:,i), x(i), y(i), method);
%!     end
%!     toc2 = cputime - tic;
%! end
%! tol = 2*cputime_res() + sqrt(eps);

% For the theory behind matlab's implementation, see Cleve Moler's textbook, 
% available at <http://www.mathworks.com/moler/chapters.html>, or directly at 
% <http://www.mathworks.com/moler/interp.pdf>.

%!test
%! % 4-by-4 implementation agrees with matlab's interp2(..., 'spline')
%! % but is faster.
%! [z, toc, z2, toc2] = doit (4, 4, 'spline');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));
%! %[N, toc, toc2, toc2-toc, toc]  % DEBUG
%! myassert (toc <= toc2 || abs(toc2-toc) <= tol);

%!test
%! % 4-by-4 implementation does NOT agree with matlab's interp2(..., 'cubic')
%! [z, toc, z2, toc2] = doit (4, 4, 'cubic');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(~all(abs(z2 - z) < sqrt(eps)));

%!test
%! % 3-by-3 implementation agrees with matlab's interp2(..., 'spline')
%! [z, toc, z2, toc2] = doit (3, 3, 'spline');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));
%! %[N, toc, toc2, toc2-toc, toc]  % DEBUG
%! myassert (toc <= toc2 || abs(toc2-toc) <= tol);

%!test
%! % 2-by-2 implementation agrees with matlab's interp2(..., 'linear')
%! [z, toc, z2, toc2] = doit (2, 2, 'linear');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));
%! %[N, toc, toc2, toc2-toc, toc]  % DEBUG
%! myassert (toc <= toc2 || abs(toc2-toc) <= tol);

%!test
%! % In case there is one node missing in the n-by-n grid, 
%! % we return NaN -- we do NOT try to use a lower degree polynomial
%! z = interp2_mbyn (0, 0, NaN, 0, 0, 1, 1);
%! myassert(isnan(z))

%!test
%! % 4-by-3 implementation agrees with matlab's interp2(..., 'spline')
%! [z, toc, z2, toc2] = doit (4, 3, 'spline');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));

%!test
%! % 3-by-4 implementation agrees with matlab's interp2(..., 'spline')
%! [z, toc, z2, toc2] = doit (3, 4, 'spline');
%! %[z, z2, z2-z]  % DEBUG
%! myassert(z2, z, -sqrt(eps));

%!test
%! % large coordinates would yield a ill-conditioned design matrix if left unnormalized:
%! X = [...
%!      2775000     2790000     2805000     2820000
%!      2775000     2790000     2805000     2820000
%!      2760000     2775000     2790000     2805000
%! ];
%! Y = [...
%!     -3990000    -3975000    -3960000    -3945000
%!     -3990000    -3975000    -3960000    -3945000
%!     -3990000    -3975000    -3960000    -3945000
%! ];
%! Z(:,:,1) = [...
%!              97824.2421875               97835.34375             97846.9140625              97865.203125
%!                   97842.25             97850.8359375              97852.421875             97866.9765625
%!               97910.484375                  97861.75              97866.421875                97877.0625
%!                   97803.25             97804.6484375              97902.078125             97896.1953125
%! ];
%! Z(:,:,2) = [...
%!            25362.220703125            25367.80859375           25375.189453125              25382.546875
%!            25364.326171875            25370.05859375           25375.818359375            25385.11328125
%!              25364.6171875           25372.431640625                25380.5625                  25386.25
%!              25366.3828125           25374.439453125           25380.853515625           25386.759765625
%! ];
%! Z(:,:,3) = [...
%!             5287.833984375          5287.87451171875           5288.1669921875           5288.6865234375
%!           5287.38525390625          5287.82373046875          5288.16162109375           5288.6611328125
%!             5287.314453125             5287.89453125          5287.87451171875          5288.22216796875
%!           5287.22900390625              5287.6171875          5287.97509765625          5288.13134765625
%! ];
%! x = [...
%!           2797245.10852527
%!           2790725.28785233
%!           2784227.20967159
%! ];
%! y = [...
%!          -3966424.70927316
%!          -3966551.90159753
%!          -3966676.65407333
%! ];
%! m = 4;
%! n = 4;
%! 
%! warning('')
%! z = interp2_mbyn (X, Y, Z, x, y, m, n);
%! [msg_str, msg_id] = lastwarn();
%! assert(~strcmp(msg_id, 'MATLAB:nearlySingularMatrix'))
%! 

