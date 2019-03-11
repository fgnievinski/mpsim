function J = get_jacobian_local2geod_viageod (base_geod, ell)
%GET_JACOBIAN_LOCAL2GEOD_VIAGEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. local Cartesian coordinates (directly).

    num_pts = size(base_geod, 1);

    k = k_diff_metric (base_geod, ell);

    J = zeros(3,3,num_pts);
    J(1,1,:) = 1./k(:, 1);
    J(2,2,:) = 1./k(:, 2);
    J(3,3,:) = 1./k(:, 3);
end

%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (1);
%! pt_local = rand(n,3);

%!test
%! % compare analytical to numerical derivatives:
%! f = @(pt_local_) convert_from_local_cart_viageod (pt_local_, base_geod, ell);
%! J = diff_func_obs (f, pt_local);
%! J2 = get_jacobian_local2geod_viageod (base_geod, ell);
%! 
%! %J, J2
%! %J - J2
%! %nthroot(eps(J), 3)
%! %(J2 - J) <= nthroot(eps(J), 3)
%! myassert (J2, J, -nthroot(eps(J), 3));

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_local2geod_viageod (repmat(base_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J= get_jacobian_local2geod_viageod (base_geod, ell);
%! J_inv  = get_jacobian_geod2local_viageod (base_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

