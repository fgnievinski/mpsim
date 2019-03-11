function J = get_jacobian_local2geod (pt_local, base_geod, ell, optimize)
%GET_JACOBIAN_LOCAL2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. local Cartesian coordinates (via global Cartesian coordinates).

    if (nargin < 4),  optimize = true;  end

    num_pts   = size(pt_local, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_bases == num_pts);

    if optimize && nnz(pt_local) == 0
        J = get_jacobian_local2geod_viageod (base_geod, ell);
        if (num_bases == 1),  J = repmat(J, [1, 1, num_pts]);  end
        return;
    end

    [ignore, pt_geod] = convert_from_local_cart (pt_local, base_geod, ell);
    J_local2cart = get_jacobian_local2cart (base_geod, ell);
    J_cart2geod  = get_jacobian_cart2geod (pt_geod, ell);
    %J_cart2geod = get_jacobian_cart2geod (base_geod, ell);  % WRONG!!!

    J = frontal_mtimes(J_cart2geod, J_local2cart);
end


%!shared
%! n = 1;
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod (1);
%! % derivative doesn't work well for very large latitudes:
%! if abs(base_geod(1)) > 85,  base_geod(1) = sign(base_geod(1))*85;  end
%! pt_local = 1e6*rand(n,3);  % use very large local coord because for small local coord even wrong implementation works.
%! [pt_cart, pt_geod] = convert_from_local_cart (pt_local, base_geod, ell);

%!test
%! % compare analytical to numerical derivatives:
%! g = @(pt_local) convert_from_local_cart (pt_local, base_geod, ell);
%! f = @(pt_local) output(@() g(pt_local), 2);
%! J = diff_func_obs (f, pt_local);
%! J2 = get_jacobian_local2geod (pt_local, base_geod, ell);
%! 
%! e = J - J2;
%! tol = nthroot(eps(), 5);  tol(tol<eps) = eps;
%! %J, J2
%! %e(:), tol(:), abs(e(:)) < tol(:)
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_local2geod (repmat(pt_local, n, 1), base_geod, ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_local2geod (pt_local, base_geod, ell);
%! J_inv = get_jacobian_geod2local (pt_local, base_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

