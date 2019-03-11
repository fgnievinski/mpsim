function R = get_radius_eulerian (pos_geod_from, pos_geod_to, ell, azim_type)
%GET_RADIUS_EULERIAN: Return the Eulerian (i.e., azimuth-dependent) ellipsoidal radius of curvature, from a given point to another point (both given in geodetic coordinates -- NOT JUST LATITUDE).

    if (nargin < 4),  azim_type = [];  end
    azim = get_radius_eulerian_azim (pos_geod_from, pos_geod_to, ell, azim_type);
    lat = pos_geod_from(:,1);
    M = get_radius_meridional (lat, ell);
    N = get_radius_normal     (lat, ell);
    azim = azim * pi/180;
    R = ( cos(azim).^2 ./ M + sin(azim).^2 ./ N ).^(-1);
    % (see Torge, eq.4.18, p.97)
end

%%
function azim = get_radius_eulerian_azim (pos_geod_from, pos_geod_to, ell, azim_type)
    if isempty(azim_type),  azim_type = 'ellipsoidal';  end
    switch azim_type
    case 'ellipsoidal'
        azim = azimuth (pos_geod_from(:,1:2), pos_geod_to(:,1:2), ...
            [ell.a ell.e], 'degrees');
    case 'spherical'
        azim = azimuth (pos_geod_from(:,1:2), pos_geod_to(:,1:2), ...
            [ell.a 0], 'degrees');
    case 'planar'
        temp = convert_to_local_sph (pos_cart_to, pos_geod_from, ell);
        azim = temp(:,2);
    end
end
