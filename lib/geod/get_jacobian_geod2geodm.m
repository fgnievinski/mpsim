function J = get_jacobian_geod2geodm (pt_geod, ell)
%GET_JACOBIAN_GEOD2GEODM: Return the Jacobian matrix of ellipsoidal arc-lengths w.r.t. geodetic coordinates.

    lat = pt_geod(:,1);
    lon = pt_geod(:,2);
      h = pt_geod(:,3);
    n = size(pt_geod,1);

    N = compute_prime_vertical_radius (lat, ell);
    M = compute_meridian_radius (lat, ell);

    % make the coordinates tube vectors (1,1,:), so that
    % each frontal page J(:,:,k) will be the Jacobian for
    % the k-th point:
    lat = reshape (lat, [1,1,n]);
    lon = reshape (lon, [1,1,n]);
      h = reshape (  h, [1,1,n]);
      N = reshape (  N, [1,1,n]);
      M = reshape (  M, [1,1,n]);
    zero = zeros(1,1,n);
    one  =  ones(1,1,n);

    k = pi/180;
    dN_dlat = k*( N.^3 .* (ell.e^2 / ell.a^2) .* sin(k*lat) .* cos(k*lat) );
    J = [...
        % first row:
        k * (M + h), ... % dlatm / dlat
        zero, ...        % dlatm / dlon
        k*lat; ...       % dlatm / dh
        % second row:
              dN_dlat .* cos(k*lat) .* (k*lon)  ...
        - k * (N + h) .* sin(k*lat) .* (k*lon), ...    % dlonm / dlat
          k * (N + h) .* cos(k*lat), ...               % dlonm / dlon
                         cos(k*lat) .* (k*lon); ...    % dlonm / dh
        % third row:
        zero, ...        % dh / dlat
        zero, ...        % dh / dlon
        one;             % dh / dh
    ];
    
    myassert( isequal(size(J), [3,3,n]) || ((n==1) && isequal(size(J), [3,3])) );
end

%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! 
%! pt_geod = rand_pt_geod (n);
%! 
%! lat = pt_geod(:, 1);
%! lon = pt_geod(:, 2);
%! h   = pt_geod(:, 3);

%!test
%! % Test against numerical derivative 
%! % (good to catch errors due to missing pi/180 factors)
%! temp = diff_func2 (@(pt) convert_to_geodm (pt, ell), pt_geod);
%! J  = reshape(temp, 3, 3);
%! J2 = get_jacobian_geod2geodm (pt_geod, ell);
%! 
%! %J, J2, J - J2, (J - J2)./J2
%! myassert (J2, J, 1e-3);  % checking relative error

%!test
%! % When a = b, the ellipsoid degenerates onto a sphere and
%! % the expressions for the derivates simplify. Here we test that case.
%! ell.b = ell.a;  ell.e = 0;  ell.f = 0;
%!
%! R = ell.a;
%! k = pi/180;
%! J = [...
%!     % first row:
%!     k * (R + h), ...
%!     0, ...
%!     k*lat; ...
%!     % second row:
%!     - k * (R + h) * sin(k*lat) * (k*lon), ...
%!       k * (R + h) * cos(k*lat), ...
%!                     cos(k*lat) * (k*lon); ...
%!     % third row:
%!     0, ...
%!     0, ...
%!     1;     
%! ];
%! J2 = get_jacobian_geod2geodm (pt_geod, ell);
%! 
%! %J, J2, J - J2
%! myassert (J2, J, -sqrt(eps));

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_geod2geodm (repmat(pt_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

