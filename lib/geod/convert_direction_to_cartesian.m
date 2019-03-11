function dir_global_cart = convert_direction_to_cartesian (...
pos_geod, elev_ang, azimuth, ell)
%CONVERT_DIRECTION_TO_CARTESIAN: Convert from elevation angle and azimuth to local direction cosines.

    if (nargin < 4)
        % spherical case; pos_geod is actually pos_sph; 
        % results do not depend on specific sphere radius employed.
        ell = get_ellipsoid('sphere');
    end
    dist = ones(size(elev_ang));
    dir_local_sph = [elev_ang azimuth dist];
    dir_global_cart = convert_from_local_sph (dir_local_sph, pos_geod, ell, true);
end

%!test
%! % convert_direction_to_cartesian()
%! test('convert_direction_from_cartesian')
