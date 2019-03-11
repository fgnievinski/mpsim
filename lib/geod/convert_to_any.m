function [pt, J] = convert_to_any (pt_cart, ell, coord_type, base_geod)
%CONVERT_TO_ANY: Convert from global Cartesian coordinates to any other type of coordinates.

    if ~any(strcmp(coord_type, {'cart', 'local', 'geodm', 'geod'}))
        error('MATLAB:convert_to_any', ...
        'Coordinate type "%s" not supported.', coord_type);
    end
    J = [];

    switch coord_type
    case 'cart'
        pt = pt_cart;
    case 'geod'
        pt_geod = convert_to_geodetic (pt_cart, ell);
        pt = pt_geod;
    case 'local'
        if (nargout < 2)
            pt_local = convert_to_local_cart (pt_cart, base_geod, ell);
        else
            [pt_local, J] = convert_to_local_cart (pt_cart, base_geod, ell);
        end
        pt = pt_local;
    case 'geodm'
        pt_geod = convert_to_geodetic (pt_cart, ell);
        pt_geodm = convert_to_geodm (pt_geod, ell);
        pt = pt_geodm;
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
%! pt = convert_to_any (pt_cart, ell, 'cart');
%! myassert (pt, pt_cart, -sqrt(eps));
%! 
%! pt = convert_to_any (pt_cart, ell, 'local', base_geod);
%! myassert (pt, pt_local, -sqrt(eps));
%! 
%! pt = convert_to_any (pt_cart, ell, 'geodm');
%! myassert (pt, pt_geodm, -sqrt(eps));
%! 
%! pt = convert_to_any (pt_cart, ell, 'geod');
%! myassert (pt, pt_geod, -sqrt(eps));

%!test
%! % convert_to_any
%! lasterror('reset');

%!error
%! convert_to_any ([], [], 'WRONG');

%!test
%! % convert_to_any
%! s = lasterror;
%! myassert (s.identifier, 'MATLAB:convert_to_any');

