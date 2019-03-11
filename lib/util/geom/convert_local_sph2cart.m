function pt_local_cart = convert_local_sph2cart (pt_local_sph)
    if isempty(pt_local_sph),  pt_local_cart = pt_local_sph;  return;  end
    
    pt_local_sph(:,end+1:3) = 1;
    pt_elev = pt_local_sph(:,1);
    pt_azim = pt_local_sph(:,2);
    pt_dist = pt_local_sph(:,3);

    phi = pt_elev * pi/180;
    theta = (90 - pt_azim) * pi/180;
    R = pt_dist;
    [x, y, z] = sph2cart(theta, phi, R);
    pt_north = y;
    pt_east  = x;
    pt_up    = z;

    pt_local_cart = [pt_north, pt_east, pt_up];
end

%!test
%! % alternative implementation:
%! function pt_local_cart = convert_local_sph2cart_alt (pt_local_sph)
%!     pt_elev = pt_local_sph(:,1) * pi/180;
%!     pt_azim = pt_local_sph(:,2) * pi/180;
%!     pt_dist = pt_local_sph(:,3);
%!     pt_zen  = (pi/2) - pt_elev;
%!     
%!     pt_north = pt_dist .* cos(pt_azim) .* sin(pt_zen);
%!     pt_east  = pt_dist .* sin(pt_azim) .* sin(pt_zen);
%!     pt_up    = pt_dist                 .* cos(pt_zen);
%! 
%!     pt_local_cart = [pt_north, pt_east, pt_up];
%! end
%! 
%! n = ceil(10*rand);
%! pt_local_cart = randint(-1,+1, n,3);
%! pt_local_sph = convert_local_cart2sph (pt_local_cart);
%! pt_local_cart = convert_local_sph2cart (pt_local_sph);
%! pt_local_cart_alt = convert_local_sph2cart_alt (pt_local_sph);
%! %pt_local_cart_alt, pt_local_cart, pt_local_cart_alt - pt_local_cart  % DEBUG
%! myassert(pt_local_cart_alt, pt_local_cart, -eps(180*pi))

