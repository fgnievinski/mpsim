function pt_local_cart = convert_local_sph2cart_hrz (pos_local_sph)
    if isempty(pos_local_sph),  pt_local_cart = pos_local_sph;  return;  end
    pos_local_sph(:,end+1:3) = 1;
    elev = pos_local_sph(:,1);
    azim = pos_local_sph(:,2);
    dist = pos_local_sph(:,3);

%     temp = cosd(elev);  % orthographic
%     temp = sind(elev);  % inside-out
    temp = 1 - sind(elev);  % outside-in
    %temp = cotd(elev);  % inside-out
    %temp = (90 - elev) * pi/180;
    %temp = sind(90-elev) ./ (1 - cosd(90-elev));  % stereographic
    %temp = sind(elev) ./ (1 - cosd(elev));  % ?
    temp = dist .* temp;
    y = temp .* cosd(azim);
    x = temp .* sind(azim);
    z = NaN(size(dist));
    
    north = y;
    east  = x;
    up    = z;

    pt_local_cart = [north, east, up];
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

