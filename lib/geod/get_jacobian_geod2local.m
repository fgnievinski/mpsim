function J = get_jacobian_geod2local (pt_local, base_geod, ell, optimize)
%GET_JACOBIAN_GEOD2LOCAL: Return the Jacobian matrix of local Cartesian coordinates w.r.t. geodetic coordinates (via global Cartesian coordinates).

    if (nargin < 4),  optimize = true;  end

    num_pts   = size(pt_local, 1);
    num_bases = size(base_geod, 1);
    myassert (num_bases == 1 || num_bases == num_pts);

    if optimize && nnz(pt_local) == 0
        J = get_jacobian_geod2local_viageod (base_geod, ell);
        if (num_bases == 1),  J = repmat(J, [1, 1, num_pts]);  end
        return;
    end

    [ignore, pt_geod] = convert_from_local_cart (pt_local, base_geod, ell);
    J_cart2local = get_jacobian_cart2local (base_geod, ell);
    J_geod2cart  = get_jacobian_geod2cart (pt_geod, ell);
    %J_geod2cart = get_jacobian_geod2cart (base_geod, ell);  % WRONG!!!

    J = frontal_mtimes(J_cart2local, J_geod2cart);
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
%! function pt_local = func (pt_geod, base_geod, ell)
%!     pt_cart = convert_to_cartesian (pt_geod, ell);
%!     pt_local = convert_to_local_cart (pt_cart, base_geod, ell);
%! end
%! f = @(pt_geod_) func (pt_geod_, base_geod, ell);
%! J = diff_func_obs (f, pt_geod);
%! J2 = get_jacobian_geod2local (pt_local, base_geod, ell);
%! 
%! e = J - J2;
%! tol = 2*100*nthroot(eps(J), 3);  tol(tol<eps) = eps;
%! %J, J2
%! %[e(:), tol(:), abs(e(:)) < tol(:)]
%! myassert (J2, J, -tol);

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_geod2local (repmat(pt_local, n, 1), base_geod, ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

%!test
%! % consistency check:
%! J = get_jacobian_geod2local (pt_local, base_geod, ell);
%! J_inv = get_jacobian_local2geod (pt_local, base_geod, ell);
%! I = J * J_inv;
%! %I - eye(3)
%! myassert (I, eye(3), -sqrt(eps))

