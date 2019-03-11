function [pt_cart, pt_geod] = convert_from_any (pt, ell, coord_type, base_geod)
%CONVERT_FROM_ANY: Convert any type of coordinates, to global Cartesian coordinates.

    switch coord_type
    case 'cart'
        pt_cart = pt;
        if (nargout > 1)
            pt_geod = convert_to_geodetic (pt_cart, ell);
        end
    case 'local'
        pt_local = pt;
        pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
        if (nargout > 1)
            pt_geod = convert_to_geodetic (pt_cart, ell);
        end
    case 'geodm'
        pt_geodm = pt;
        pt_geod = convert_from_geodm (pt_geodm, ell);
        pt_cart = convert_to_cartesian (pt_geod, ell);
    case 'geod'
        pt_geod = pt;
        pt_cart = convert_to_cartesian (pt_geod, ell);
    otherwise
        error('MATLAB:convert_from_any', ...
        'Coordinate type "%s" not supported.', coord_type);
    end
end

%!test
%! ell = get_ellipsoid('grs80');
%! base_geod = rand_pt_geod;
%! pt_local = rand(1,3) * 100;
%! pt_cart = convert_from_local_cart (pt_local, base_geod, ell);
%! pt_geod = convert_to_geodetic (pt_cart, ell);
%! pt_geodm = convert_to_geodm (pt_geod, ell);
%! 
%! pt_cart2 = convert_from_any (pt_cart, ell, 'cart');
%! myassert (pt_cart2, pt_cart, -sqrt(eps));
%! 
%! pt_cart2 = convert_from_any (pt_local, ell, 'local', base_geod);
%! myassert (pt_cart2, pt_cart, -sqrt(eps));
%! 
%! pt_cart2 = convert_from_any (pt_geodm, ell, 'geodm');
%! myassert (pt_cart2, pt_cart, -sqrt(eps));
%! 
%! pt_cart2 = convert_from_any (pt_geod, ell, 'geod');
%! myassert (pt_cart2, pt_cart, -sqrt(eps));

%!test
%! % convert_from_any
%! lasterror('reset');

%!error
%! convert_from_any ([], [], 'WRONG');

%!test
%! % convert_from_any
%! s = lasterror;
%! myassert (s.identifier, 'MATLAB:convert_from_any')

