function J = get_jacobian_cart2local (base_geod, ell)
%GET_JACOBIAN_CART2LOCAL: Return the Jacobian matrix of local Cartesian coordinates w.r.t. global Cartesian coordinates (directly).

    J_inv = get_jacobian_local2cart (base_geod, ell);
    J = frontal_transpose(J_inv);
end

%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (1);
%! pt_local = rand(1, 3);
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);

%!test
%! % compare analytical to numerical derivatives:
%! f = @(pt_cart_) convert_to_local_cart (pt_cart_, base_geod, ell);
%! J = diff_func_obs (f, pt_cart);
%! J2 = get_jacobian_cart2local (base_geod, ell);
%! 
%! e = J - J2;
%! tol = 2*100*nthroot(eps(J), 3);  tol(tol<eps) = eps;
%! %J, J2, e, tol
%! %[e(:), tol(:), abs(e(:)) < tol(:)]
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_cart2local (repmat(base_geod(1,:), n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! %J - repmat(J(:,:,1), [1, 1, n])
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_local2cart (base_geod, ell);
%! J_inv = get_jacobian_cart2local (base_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

