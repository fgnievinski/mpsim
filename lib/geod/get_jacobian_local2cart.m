function J = get_jacobian_local2cart (base_geod, ell)
%GET_JACOBIAN_LOCAL2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. local Cartesian coordinates (directly).

    num_pts = size(base_geod, 1);

    % Formulas from:
    % Seeber, Satellite Geodesy. 2003. 2nd edition. p. 24-25.
    lat = base_geod(:,1);  lon = base_geod(:,2);
    R2 = get_rot (2,  90-lat);
    R3 = get_rot (3, 180-lon);
    S2 = repmat(diag([1, -1, 1]), [1,1,num_pts]);
    %S2 = diag([1, -1, 1]);

    J = frontal_mtimes(frontal_mtimes(R3, R2), S2);
end

%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (1);
%! pt_local = rand(1, 3);

%!test
%! % compare to independent implementation:
%! % Formulas from:
%! % Seeber, Satellite Geodesy. 2003. 2nd edition. p. 25.
%! lat = base_geod(:,1);  lon = base_geod(:,2);
%! k = pi/180;
%! J = [...
%!     % first row:
%!     - sin(k*lat) .* cos(k*lon), ... 
%!                   - sin(k*lon), ... 
%!     + cos(k*lat) .* cos(k*lon);     
%!     % second row:
%!     - sin(k*lat) .* sin(k*lon), ... 
%!                   + cos(k*lon), ... 
%!     + cos(k*lat) .* sin(k*lon);     
%!     % third row:
%!     + cos(k*lat), ...               
%!     + zeros(1,1,n), ...             
%!     + sin(k*lat);                   
%! ];
%! J2 = get_jacobian_local2cart (base_geod, ell);
%! %J, J2
%! myassert (J2, J, -10*eps)

%!test
%! % compare analytical to numerical derivatives:
%! f = @(pt_local_) convert_from_local_cart (pt_local_, base_geod, ell);
%! J = diff_func_obs (f, pt_local);
%! J2 = get_jacobian_local2cart (base_geod, ell);
%! 
%! e = J - J2;
%! tol = 2*100*nthroot(eps(J), 3);  tol(tol<eps) = eps;
%! %J, J2, e, tol
%! %[e(:), tol(:), abs(e(:)) < tol(:)]
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_local2cart (repmat(base_geod(1,:), n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! %J - repmat(J(:,:,1), [1, 1, n])
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_cart2local (base_geod, ell);
%! J_inv = get_jacobian_local2cart (base_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

