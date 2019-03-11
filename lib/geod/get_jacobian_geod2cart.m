function J = get_jacobian_geod2cart (pt_geod, ell)
%GET_JACOBIAN_GEOD2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. geodetic coordinates.

    J_geod2local = get_jacobian_geod2local_viageod (pt_geod, ell);
    J_local2cart = get_jacobian_local2cart (pt_geod, ell);
    J = frontal_mtimes(J_local2cart, J_geod2local);
end

%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! 
%! pt_geod = rand_pt_geod (n);
%! %pt_geod = [89 0 0]
%! 
%! lat = pt_geod(:, 1);
%! lon = pt_geod(:, 2);
%! h   = pt_geod(:, 3);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_geod2cart (repmat(pt_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % numerical derivative:
%! temp = diff_func2 (@(pt) convert_to_cartesian (pt, ell), pt_geod);
%! J  = reshape(temp, 3, 3);
%! J2 = get_jacobian_geod2cart (pt_geod, ell);
%! 
%! %J, J2, J - J2, 1e-3*J2
%! myassert (J2, J, -1e-3);

%!test
%! % When the uncertainty in latitude and longitude are both zero,
%! % an uncertainty along the height direction propagates entirely
%! % into the normal direction. We test here the simple cases
%! % where the normal direction coincides with the X, Y, or Z axis.
%! tol = sqrt(eps);
%! 
%! h_std = rand;
%! geod_std = [0 0 h_std];
%! for axis={'X','Y','Z'};  axis = axis{:};
%!     switch axis
%!     case 'X'
%!         % Normal direction coincides with the X axis, -X.
%!         pt_geod = [0 0 0];
%!         cart_std = [h_std 0 0];
%!         ind = 1;
%!     case 'Y'
%!         % Normal direction coincides with the Y axis, -Y.
%!         pt_geod = [0 -90 0];
%!         cart_std = [0 h_std 0];
%!         ind = 2;
%!     case 'Z'
%!         % Normal direction coincides with the Z axis, -Z.
%!         pt_geod = [-90 0 0];
%!         cart_std = [0 0 h_std];
%!         ind = 3;
%!     end
%!     %pt_geod, cart_std, ind
%! 
%!     B = get_jacobian_geod2cart (pt_geod, ell);
%!     temp = propagate_cov (diag(geod_std.^2), B);
%!       h_std2 = sqrt(temp(ind,ind));
%! 
%!     B = get_jacobian_cart2geod (pt_geod, ell);
%!     temp = propagate_cov (diag(cart_std.^2), B);
%!       h_std3 = sqrt(temp(3,3));
%! 
%!     %[h_std, h_std2, h_std3]
%!     %[h_std2 - h_std, h_std3 - h_std]
%!     myassert (h_std2, h_std, -tol);
%!     myassert (h_std3, h_std, -tol);
%! end

%!test
%! % When a = b, the ellipsoid degenerates onto a sphere and
%! % the expressions for the derivates simplify. Here we test that case.
%! ell.b = ell.a;  ell.e = 0;
%!
%! R = ell.a;
%! k = pi/180;
%! J = [...
%!     % first row:
%!      -k*(R+h)*sin(k*lat)*cos(k*lon), ...
%!      -k*(R+h)*cos(k*lat)*sin(k*lon), ...
%!               cos(k*lat)*cos(k*lon); ...
%!     % second row:
%!      -k*(R+h)*sin(k*lat)*sin(k*lon), ...
%!       k*(R+h)*cos(k*lat)*cos(k*lon), ...
%!               cos(k*lat)*sin(k*lon); ...
%!     % third row:
%!       k*(R+h)*cos(k*lat), ...
%!              0, ...
%!              sin(k*lat);
%! ];
%! J2 = get_jacobian_geod2cart (pt_geod, ell);
%! 
%! %J, J2, J - J2, 1e-3*J2
%! myassert (J2, J, -sqrt(eps));

%!test
%! % The partial derivatives of X, Y, Z with respect to latitude,
%! % which correspond to elements J(:, 1) of the Jacobian, 
%! % can also be computed by the expressions below.
%! % Those expressions can be obtained by deriving the derivatives
%! % but NOT substituting into them the derivative of N with respect 
%! % to latitude (dN_dlat).
%!
%! k = pi/180;
%! 
%! a = ell.a;  b = ell.b;  e = ell.e;
%! N = compute_prime_vertical_radius (pt_geod(:, 1), ell);
%! dN_dlat = k*( N^3 * (e^2 / a^2) * sin(k*lat) * cos(k*lat) );
%! 
%! r = (b/a)^2;
%! dXYZ_dlat = [...
%! -k*(N  +h)*sin(k*lat)*cos(k*lon) + dN_dlat  *cos(k*lat)*cos(k*lon);
%! -k*(N  +h)*sin(k*lat)*sin(k*lon) + dN_dlat  *cos(k*lat)*sin(k*lon);
%!  k*(N*r+h)*cos(k*lat)            + dN_dlat*r*sin(k*lat);
%! ];
%! %B(1, 1) = - (N + h) * sin(lat) * cos(lon) + dN_dlat * cos(lat) * cos(lon);
%! %B(2, 1) = - (N + h) * sin(lat) * sin(lon) + dN_dlat * cos(lat) * sin(lon);
%! %B(3, 1) = (N * (b^2/a^2) + h) * cos(lat) + (b^2/a^2) * dN_dlat * sin(lat);
%! 
%! J2 = get_jacobian_geod2cart (pt_geod, ell);
%! 
%! %dXYZ_dlat, J2(:, 1), J2(:, 1) - dXYZ_dlat, abs(J2(:, 1) - dXYZ_dlat)./dXYZ_dlat  % DEBUG
%! myassert (J2(:,1), dXYZ_dlat, -sqrt(eps));

%!test
%! % different implementation:
%! J  = get_jacobian_geod2cartb (pt_geod, ell);
%! J2 = get_jacobian_geod2cart  (pt_geod, ell);
%! 
%! %J, J2, J-J2
%! myassert (J, J2, -sqrt(eps));
%! 
%! function J = get_jacobian_geod2cartb (pt_geod, ell)
%!     lat = pt_geod(:,1);
%!     lon = pt_geod(:,2);
%!       h = pt_geod(:,3);
%!     n = size(pt_geod,1);
%! 
%!     N = compute_prime_vertical_radius (lat, ell);
%!     M = compute_meridian_radius (lat, ell);
%! 
%!     % make the coordinates tube vectors (1,1,:), so that
%!     % each frontal page J(:,:,k) will be the Jacobian for
%!     % the k-th point:
%!     lat = reshape (lat, [1,1,n]);
%!     lon = reshape (lon, [1,1,n]);
%!       h = reshape (  h, [1,1,n]);
%!       N = reshape (  N, [1,1,n]);
%!       M = reshape (  M, [1,1,n]);
%! 
%!     k = pi/180;
%!     J = [...
%!         % first row:
%!         -k*(M+h) .* sin(k*lat) .* cos(k*lon), ...   % dX / dlat
%!         -k*(N+h) .* cos(k*lat) .* sin(k*lon), ...   % dX / dlon
%!                     cos(k*lat) .* cos(k*lon);       % dX / dh
%!         % second row:
%!         -k*(M+h) .* sin(k*lat) .* sin(k*lon), ...   % dY / dlat
%!         +k*(N+h) .* cos(k*lat) .* cos(k*lon), ...   % dY / dlon
%!                     cos(k*lat) .* sin(k*lon);       % dY / dh
%!         % third row:
%!         +k*(M+h) .* cos(k*lat), ...                 % dZ / dlat
%!         zeros(1,1,n), ...                           % dZ / dlon
%!                     sin(k*lat);                     % dZ / dh
%!     ];
%!     
%!     myassert( isequal(size(J), [3,3,n]) || ((n==1) && isequal(size(J), [3,3])) );
%! end

%!test
%! % consistency between forward/reverse:
%! J = get_jacobian_geod2cart (pt_geod, ell);
%! J_inv = get_jacobian_cart2geod (pt_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert(I, eye(3), -sqrt(eps))

