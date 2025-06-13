function coord_sph = convert_to_spherical (coord_cart)
%CONVERT_TO_SPHERICAL: Convert to global spherical coordinates, given global Cartesian coordinates.

    if isempty(coord_cart),  coord_sph = coord_cart;  return;  end
    if size(coord_cart, 2) > 3
        error ('Positions should be given one colum for each coordinate (therefore 3 columns), one row per point.');
    end

    x = coord_cart(:, 1);
    y = coord_cart(:, 2);
    z = coord_cart(:, 3);
    
    lon = atan2(y, x);
    
    p = sqrt(x.^2 + y.^2);
    lat = atan2(z, p);
    
    r = sqrt(x.^2 + y.^2 + z.^2);
    %h = r - sph.a;
    
    coord_sph = [lat*180/pi, lon*180/pi, r];

return;

%!test
%! % Points on a sphere, random latitudes, random longitudes, random heights.
%! error_lat = 1e-13; error_r = 1e-8; error_lon = 1e-13;
%! a = 6378206.4;  b = a;  e = 0;
%! ellips_nad27.a = a;  ellips_nad27.b = b;  ellips_nad27.e = e;
%!
%! n = 15;
%! lat = rand(n, 1)*180 - 90;   % random latitudes between [-90, +90)
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! r = h + ellips_nad27.a;      % radii
%!
%! x = r .* cos(lon * pi/180) .* cos(lat * pi/180);
%! y = r .* sin(lon * pi/180) .* cos(lat * pi/180);
%! z = r                      .* sin(lat * pi/180);
%! coord_cart = [x y z];
%! 
%! answer_coord_geod = convert_to_spherical (coord_cart);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_r = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_r - r) <= error_r) );

