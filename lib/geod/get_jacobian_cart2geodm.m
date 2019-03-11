function J = get_jacobian_cart2geodm (pt_geod, ell)
%GET_JACOBIAN_GEOD2GEODM: Return the Jacobian matrix of ellipsoidal arc-lengths w.r.t. global Cartesian coordinates.

    J_geod2geodm = get_jacobian_geod2geodm (pt_geod, ell);
    J_cart2geod  = get_jacobian_cart2geod  (pt_geod, ell);
    J = frontal_mtimes(J_geod2geodm, J_cart2geod);
end

%!shared
%! %rand('seed', 0)
%! ell = get_ellipsoid('grs80');
%! pt_geod = rand_pt_geod;
%! pt_cart = convert_to_cartesian(pt_geod, ell);

%!test
%! % compare analytical to numerical derivatives:
%! function pt_geodm = func (pt_cart, ell)
%!     pt_geod = convert_to_geodetic (pt_cart, ell);
%!     pt_geodm = convert_to_geodm (pt_geod, ell);
%! end
%! f = @(pt) func (pt, ell);
%! temp = diff_func2 (f, pt_cart);
%! J  = reshape(temp, 3, 3);
%! J2 = get_jacobian_cart2geodm (pt_geod, ell);
%! 
%! e = J - J2;
%! tol = 2*1e-3;
%! %J, J2, e  % DEBUG
%! %[e(:), tol(:), abs(e(:)) < tol(:)]
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_cart2geodm (repmat(pt_geod(1,:), n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! %J - repmat(J(:,:,1), [1, 1, n])
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_geodm2cart (pt_geod, ell);
%! J_inv = get_jacobian_cart2geodm (pt_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

