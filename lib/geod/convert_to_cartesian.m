function coord_cart = convert_to_cartesian (coord_geod, ell)
%CONVERT_TO_CARTESIAN: Convert to global Cartesian coordinates, given geodetic curvilinear coordinates.

    if (nargin < 2) || isempty(ell),  ell = get_ellipsoid();  end
    if isempty(coord_geod)
        coord_cart = zeros(size(coord_geod));
        %coord_cart = [];  % WRONG!
        return;
    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Auxiliary quantities

    % radius of curvature of the prime vertical section
    N = compute_prime_vertical_radius (coord_geod(:, 1), ell);

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Some shortnames for variables used often.
    a = ell.a;  b = ell.b;
    
    lat = coord_geod(:, 1) * (pi/180);
    lon = coord_geod(:, 2) * (pi/180);
    h   = coord_geod(:, 3);
    
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute cartesian (geocentric) coordinates given 
    % (curvilinear) geodetic coordinates.
    x = (N + h) .* cos(lat) .* cos(lon);
    y = (N + h) .* cos(lat) .* sin(lon);
    z = (N .* (b/a)^2 + h) .* sin(lat);
    coord_cart = [x y z];
    
end

%!shared
%! n = 10;  % number of points in each test set
%! 
%! % The error below was determied experimentally, running all 
%! % tests below.
%! error = 1e-8;
%!
%! a = 6378206.4;  b = 6356583.8;  e = sqrt ( (a^2 - b^2) / (a^2));
%! ell.a = a;  ell.b = b;  ell.e = e;

%!test
%! % Points at south pole, random heights, random longitudes.
%! lat = -90*ones(n, 1);
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! x = zeros(n, 1);
%! y = zeros(n, 1);
%! z = -(ell.b+h);
%! correct_answer = [x y z];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! myassert ( all(abs(coord_cart - correct_answer) < error) );

%!test
%! % Points on equatorial plane, at Greenwich meridian, random heights.
%! lat = 0*ones(n, 1);
%! lon = 0*ones(n, 1);
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! x = (ell.a+h);
%! y = zeros(n, 1);
%! z = zeros(n, 1);
%! correct_answer = [x y z];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! myassert ( all(abs(coord_cart - correct_answer) < error) );

%!test
%! % Points on equatorial plane, at +90 degrees meridian, random heights.
%! lat = 0*ones(n, 1);
%! lon = +90*ones(n, 1);
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! x = zeros(n, 1);
%! y = (ell.a+h);
%! z = zeros(n, 1);
%! correct_answer = [x y z];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! myassert ( all(abs(coord_cart - correct_answer) < error) );

%!test
%! % Points on equatorial plane, at -90 degrees meridian, random heights.
%! lat = 0*ones(n, 1);
%! lon = -90*ones(n, 1);
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! x = zeros(n, 1);
%! y = -(ell.a+h);
%! z = zeros(n, 1);
%! correct_answer = [x y z];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! myassert ( all(abs(coord_cart - correct_answer) < error) );

%!test
%! % Points on equatorial plane, at 180 degrees meridian, random heights.
%! lat = 0*ones(n, 1);
%! lon = 180*ones(n, 1);
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! x = -(ell.a+h);
%! y = zeros(n, 1);
%! z = zeros(n, 1);
%! correct_answer = [x y z];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! myassert ( all(abs(coord_cart - correct_answer) < error) );

%!test
%! % Points on equatorial plane, random longitudes, random heights.
%! lat = 0*ones(n, 1);
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat, lon, h];
%! 
%! coord_cart = convert_to_cartesian (coord_geod, ell);
%! x = coord_cart(:, 1);
%! y = coord_cart(:, 2);
%! z = coord_cart(:, 3);
%! equatorial_radius = sqrt(x.^2 + y.^2) - h;
%! 
%! myassert ( all( abs( equatorial_radius - ell.a*ones(n, 1) ) < error) );
%! myassert ( all( abs( z - 0 ) < error) );

%!test
%! % Points on a sphere, random latitudes, random longitudes, random heights.
%! a = 6378206.4;  b = a;  e = sqrt ( (a^2 - b^2) / (a^2));
%! ell.a = a;  ell.b = b;  ell.e = e;
%!
%! lat = rand(n, 1)*180 - 90;   % random latitudes between [-90, +90)
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! coord_geod = [lat lon h];
%!
%! % sherical formulas:
%! x = (h + ell.a) .* cos(lon * pi/180) .* cos(lat * pi/180);
%! y = (h + ell.a) .* sin(lon * pi/180) .* cos(lat * pi/180);
%! z = (h + ell.a)                      .* sin(lat * pi/180);
%! coord_cart = [x y z];
%! 
%! answer_coord_cart = convert_to_cartesian (coord_geod, ell);
%! answer_x = coord_cart(:, 1);
%! answer_y = coord_cart(:, 2);
%! answer_z = coord_cart(:, 3);
%! 
%! %answer_coord_cart - coord_cart
%! myassert ( all(abs(answer_x - x) <= error) );
%! myassert ( all(abs(answer_y - y) <= error) );
%! myassert ( all(abs(answer_z - z) <= error) );

%!test
%! % empty in, empty out.
%! myassert(isempty(convert_to_cartesian([])));

