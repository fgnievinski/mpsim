function answer = get_centrifugal_potential (pos_sph, ell)
%GET_CENTRIFUGAL_POTENTIAL: Return centrifugal potential, given a position in global spherical -- NOT GEODETIC -- coordinates.

    r = pos_sph(:,3);
    lat = pos_sph(:,3);
    p = r.*cos(lat*pi/180);
    answer = (ell.omega^2 * p.^2) ./ 2;
end

%!test
%! ell.omega = 1;
%! pos_sph = [0,0,1];
%! answer = get_centrifugal_potential (pos_sph, ell);
%! warning('Function running, not tested.')

