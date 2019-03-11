function J = get_jacobian_geodm2cart (pt_geod, ell)
%GET_JACOBIAN_GEODM2CART: Return the Jacobian matrix of global Cartesian coordinates w.r.t. ellipsoidal arc-lengths.

    J_geod2cart = get_jacobian_geod2cart  (pt_geod, ell);
    J_geodm2geod = get_jacobian_geodm2geod (pt_geod, ell);
    J = frontal_mtimes(J_geod2cart, J_geodm2geod);
end

%!shared
%! %rand('seed', 0)
%! ell = get_ellipsoid('grs80');
%! pt_geod = rand_pt_geod;
%! pt_geodm = convert_to_geodm(pt_geod, ell);

%!test
%! % compare analytical to numerical derivatives:
%! function pt_cart = func (pt_geodm, ell)
%!     pt_geod = convert_from_geodm (pt_geodm, ell);
%!     pt_cart = convert_to_cartesian (pt_geod, ell);
%! end
%! f = @(pt) func (pt, ell);
%! temp = diff_func2 (f, pt_geodm);
%! J  = reshape(temp, 3, 3);
%! J2 = get_jacobian_geodm2cart (pt_geod, ell);
%! 
%! e = J - J2;
%! tol = 2*1e-3;
%! %J, J2, e  % DEBUG
%! %[e(:), tol(:), abs(e(:)) < tol(:)]
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_geodm2cart (repmat(rand_pt_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_geodm2cart (pt_geod, ell);
%! J_inv = get_jacobian_cart2geodm (pt_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

