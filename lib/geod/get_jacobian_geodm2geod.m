function B_inv = get_jacobian_geodm2geod (pt_geod, ell)
%GET_JACOBIAN_GEODM2GEOD: Return the Jacobian matrix of geodetic coordinates w.r.t. ellipsoidal arc-lengths.

    B = get_jacobian_geod2geodm (pt_geod, ell);
    warning('off', 'MATLAB:nearlySingularMatrix');
    B_inv = frontal_inv(B);
    warning('on', 'MATLAB:nearlySingularMatrix');
    %TODO: write down analytical expressions.
    %TODO: then change input argument to pt_cart?
end

%!shared
%! ell = get_ellipsoid('grs80');
%! pt_geod = rand_pt_geod;

%!test
%! pt_geodm = convert_to_geodm (pt_geod, ell);
%! temp = diff_func2 (@(pt) convert_from_geodm (pt, ell), pt_geodm);
%! J  = reshape(temp, 3, 3);
%! 
%! J2 = get_jacobian_geodm2geod (pt_geod, ell);
%! 
%! Je = J - J2;
%! %J, J2, Je, max(abs(Je(:)))
%! myassert (J2, J, -1e-3); % this should be beter with analytical expr.

%!test
%! % Test multiple points
%! n = 4;
%! J = get_jacobian_geodm2geod (repmat(pt_geod, n, 1), ell);
%! myassert (size(J), [3,3,n]);
%! myassert (J, repmat(J(:,:,1), [1, 1, n]));

