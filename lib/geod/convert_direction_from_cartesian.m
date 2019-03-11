function [elev, azim, pos_local_cart] = convert_direction_from_cartesian (...
pos_geod, dir_cart, ell)
%CONVERT_DIRECTION_FROM_CARTESIAN: Convert from local direction cosines to elevation angle and azimuth.

    if (nargin < 3)
        % spherical case; pos_geod is actually pos_sph; 
        % results do not depend on specific sphere radius employed.
        ell = get_ellipsoid('sphere');
    end
    [pos_local_sph, pos_local_cart] = convert_to_local_sph (dir_cart, pos_geod, ell, true);
    elev = pos_local_sph(:,1);
    azim = pos_local_sph(:,2);
    %pos_local_sph(3)-1  % DEBUG
    %myassert(pos_local_sph(3), 1, -sqrt(eps))
end

%!test
%! % self consistency check:
%! ell = get_ellipsoid('grs80');
%! pos_geod  = rand_pos_geod;
%! pos_geod2 = rand_pos_geod;
%! pos_cart  = convert_to_cartesian (pos_geod,  ell);
%! pos_cart2 = convert_to_cartesian (pos_geod2, ell);
%! temp = pos_cart2 - pos_cart;
%! dir_cart = temp ./ repmat(norm_all(temp), 1, 3);
%! 
%! [elev2, azim2] = convert_direction_from_cartesian (pos_geod, dir_cart, ell);
%! dir_cart2 = convert_direction_to_cartesian (pos_geod, elev2, azim2, ell);
%! 
%! %[dir_cart2; dir_cart; dir_cart2-dir_cart]  % DEBUG
%! myassert(dir_cart2, dir_cart, -sqrt(eps))
%! %myassert(elev2, elev, -100*eps)
%! %myassert(azim2, azim, -100*eps)

