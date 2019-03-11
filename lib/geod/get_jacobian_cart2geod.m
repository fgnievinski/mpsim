function J = get_jacobian_cart2geod (pt_geod, ell)
%GET_JACOBIAN_CART2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. global Cartesian coordinates.

    J_cart2local = get_jacobian_cart2local (pt_geod, ell);
    J_local2geod = get_jacobian_local2geod_viageod (pt_geod, ell);
    J = frontal_mtimes(J_local2geod, J_cart2local);
end

%!shared
%! ell = get_ellipsoid('grs80');
%! pt_geod = rand_pt_geod;

%!test
%! pt_cart = convert_to_cartesian (pt_geod, ell);
%! temp = diff_func2 (@(pt) convert_to_geodetic (pt, ell), pt_cart);
%! J  = reshape(temp, 3, 3);
%! 
%! J2 = get_jacobian_cart2geod (pt_geod, ell);
%! 
%! Je = J - J2;
%! Jer = Je ./ J2;
%! %J, J2, Je, Jer, max(abs(Je(:))), max(abs(Jer(:)))
%! %fprintf('%e\n', max(abs(Je(:))))
%! myassert (J2, J, -1e-3); % this should be beter with analytical expr.

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_cart2geod (repmat(pt_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency between forward/reverse:
%! J = get_jacobian_cart2geod (pt_geod, ell);
%! J_inv = get_jacobian_geod2cart (pt_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert(I, eye(3), -sqrt(eps))

