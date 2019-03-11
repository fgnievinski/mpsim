function pt_local_sph = convert_local_cart2sph (pt_local_cart)
    pt_north = pt_local_cart(:,1);
    pt_east  = pt_local_cart(:,2);
    if (size(pt_local_cart,2) == 3)
        pt_up = pt_local_cart(:,3);
    else
        pt_up = zeros(size(pt_local_cart,1),1);
    end

    x = pt_east;
    y = pt_north;
    z = pt_up;
    %[theta, phi, R] = cart2sph(x, y, z);
    %pt_azim = 90 - theta*180/pi;  % (see test case below for zenith dir)
    [theta, phi, R] = cart2sph(y, x, z);
    pt_azim = theta*180/pi;
    pt_elev = phi*180/pi;
    pt_dist = R;

    pt_local_sph = [pt_elev, pt_azim, pt_dist];
end

%!test
%! % alternative implementation:
%! function pt_local_sph = convert_local_cart2sph_alt (pt_local_cart)
%!     pt_north = pt_local_cart(:,1);
%!     pt_east  = pt_local_cart(:,2);
%!     pt_up    = pt_local_cart(:,3);
%! 
%!     pt_dist = sqrt(pt_north.^2 + pt_east.^2 + pt_up.^2);
%!     pt_azim = atan2(pt_east, pt_north) .* 180/pi;
%!     pt_zen  = acos(pt_up ./ pt_dist) .* 180/pi;
%!     pt_elev = 90 - pt_zen;
%! 
%!     pt_local_sph = [pt_elev, pt_azim, pt_dist];
%! end
%! 
%! n = ceil(10*rand);
%! pt_local_cart = randint(-1,+1, n,3);
%! pt_local_sph = convert_local_cart2sph (pt_local_cart);
%! pt_local_sph_alt = convert_local_cart2sph_alt (pt_local_cart);
%! %pt_local_sph_alt, pt_local_sph, pt_local_sph_alt - pt_local_sph  % DEBUG
%! pt_local_sph = mod(pt_local_sph, 360);
%! pt_local_sph_alt = mod(pt_local_sph_alt, 360);
%! myassert(pt_local_sph_alt, pt_local_sph, -eps(180*pi))

%!test
%! % poorly determined azimuth:
%! pos_cart = [-1.3263e-016 -2.9378e-016 1]
%! pos_sph = convert_local_cart2sph (pos_cart)
%! % (nothing to test here, just be aware.)

%!test
%! % zenith direction has zero azimuth by convention:
%! pos_cart = [0 0 1];
%! pos_sph = [90 0 1];
%! pos_sph2 = convert_local_cart2sph (pos_cart);
%! myassert(pos_sph2, pos_sph, -sqrt(eps()))
