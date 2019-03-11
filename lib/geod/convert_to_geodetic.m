function coord_geod = convert_to_geodetic (coord_cart, ell, method)
%CONVERT_TO_GEODETIC: Convert to geodetic (ellipsoidal curvilinear) coordinates, given global Cartesian coordinates.

    if (nargin < 2) || isempty(ell),  ell = get_ellipsoid();  end
    if (nargin < 3)
        method = 'vec';
%        method = 'jones';
    end
    method = lower(method);
    if ~any(strcmp(method(1), {'c','j','v'}))
        error ('Method "%s" unknown.', method);
    end

    if isstruct(ell) && ~isfield(ell, 'f')
        ell.f = 1 - sqrt(1 - ell.e^2);
    end
    
    if isempty(coord_cart)
        coord_geod = zeros(size(coord_cart));
        %coord_geod = [];  % WRONG!
        return;
    end
    
    num_pts = size(coord_cart, 1);
    coord_geod = zeros(size(coord_cart));
    
    if (method(1) == 'v')  % jones vectorized
        x = coord_cart(:, 1);
        y = coord_cart(:, 2);
        z = coord_cart(:, 3);
        [lat lon h] = convert_to_geodetic_jones_vec (x, y, z, ell);
        coord_geod = [lat*180/pi lon*180/pi h];
        return;
    end
        
    for i = 1:num_pts
        x = coord_cart(i, 1);
        y = coord_cart(i, 2);
        z = coord_cart(i, 3);
       
        switch method(1)
        case 'c'
            [lat lon h] = convert_to_geodetic_classical (x, y, z, ell);
        case 'j' 
            [lat lon h] = convert_to_geodetic_jones (x, y, z, ell);
        end

        coord_geod(i, :) = [lat*180/pi lon*180/pi h];
    end
return;


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Test block.

%!shared n, ellips, ellips, error_lat, error_h, error_lon, methods
%! rand('seed',0)
%! n = 10;  % number of points in each test set
%! % The errors below were determied experimentally, running all 
%! % tests below. Note that the tolerance (as used in this 
%! % function) does not guarantee an error with similar magnitude.
%! error_lat = 1e-13; error_h = 1e-8; error_lon = 1e-13;
%!
%! a = 6378206.4;  b = 6356583.8;  e = sqrt ( (a^2 - b^2) / (a^2));
%! ellips.a = a;  ellips.b = b;  ellips.e = e;
%! 
%! methods = ['c', 'j', 'v'];

% TEST TOL

%!test
%! % NaN in, NaN out.
%! for method=methods
%! %method
%! answer_coord_geod = convert_to_geodetic ([a a a; NaN NaN NaN], ellips, method);
%! myassert ( all(~isnan(answer_coord_geod(1,:))) );
%! myassert ( all(isnan(answer_coord_geod(2,:))) );
%! end

%!test
%! % Points at north pole, random heights.
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! 
%! x = 0 * ones(n, 1);
%! y = 0 * ones(n, 1);
%! z = h + ellips.b * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = +90*ones(n, 1);
%! 
%! for method=methods
%! %method
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! % Don't need to test longitude because it can assume any value.
%! end

%!test
%! % Points at south pole, random heights.
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%! 
%! x = 0 * ones(n, 1);
%! y = 0 * ones(n, 1);
%! z = -(h + ellips.b * ones(n, 1));
%! coord_cart = [x y z];
%! 
%! lat = -90*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! % Don't need to test longitude because it can assume any value.
%! end

%!test
%! % Points on equatorial plane, at Greenwich meridian, random heights.
%! %disp('Points on equatorial plane, at Greenwich meridian, random heights.')
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = h + ellips.a * ones(n, 1);
%! y = 0 * ones(n, 1);
%! z = 0 * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = 0*ones(n, 1);
%! lon = 0*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on equatorial plane, at +90 degrees meridian, random heights.
%! %disp('Points on equatorial plane, at +90 degrees meridian, random heights.')
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = 0 * ones(n, 1);
%! y = h + ellips.a * ones(n, 1);
%! z = 0 * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = 0*ones(n, 1);
%! lon = +90*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on equatorial plane, at -90 degrees meridian, random heights.
%! %disp('Points on equatorial plane, at -90 degrees meridian, random heights.')
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = 0 * ones(n, 1);
%! y = -(h + ellips.a * ones(n, 1));
%! z = 0 * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = 0*ones(n, 1);
%! lon = -90*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on equatorial plane, at 180 degrees meridian, random heights.
%! %disp('Points on equatorial plane, at 180 degrees meridian, random heights.')
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = -(h + ellips.a * ones(n, 1));
%! y = 0 * ones(n, 1);
%! z = 0 * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = 0*ones(n, 1);
%! lon = 180*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on equatorial plane, random longitudes, random heights.
%! %disp('Points on equatorial plane, random longitudes, random heights.')
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = (h + ellips.a) .* cos(lon * pi/180);
%! y = (h + ellips.a) .* sin(lon * pi/180);
%! z = 0 * ones(n, 1);
%! coord_cart = [x y z];
%! 
%! lat = 0*ones(n, 1);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! %max(answer_lon - lon)
%! %max(answer_h - h)
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on a sphere, random latitudes, random longitudes, random heights.
%! %disp('Points on a sphere, random latitudes, random longitudes, random heights.')
%! ellips.a = 6370e3;  ellips.b = ellips.a;  ellips.e = 0;  ellips.f = 0;
%!
%! lat = rand(n, 1)*180 - 90;   % random latitudes between [-90, +90)
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! x = (h + ellips.a) .* cos(lon * pi/180) .* cos(lat * pi/180);
%! y = (h + ellips.a) .* sin(lon * pi/180) .* cos(lat * pi/180);
%! z = (h + ellips.a)                      .* sin(lat * pi/180);
%! coord_cart = [x y z];
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on an ellipsoid, random latitudes, random longitudes,random heights.
%! %disp('Points on an ellipsoid, random latitudes, random longitudes,random heights.')
%! a = 6378206.4;  b = a;  e = sqrt ( (a^2 - b^2) / (a^2));
%! ellips.a = a;  ellips.b = b;  ellips.e = e;
%!
%! lat = rand(n, 1)*180 - 90;   % random latitudes between [-90, +90)
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! h = rand(n, 1) * 200 - 100;  % random heights between [-100, +100)
%!
%! coord_cart = convert_to_cartesian ([lat lon h], ellips);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

%!test
%! % Points on an ellipsoid, random latitudes, random longitudes, 
%! % random heights commonly found in GPS satellites.
%! a = 6378206.4;  b = a;  e = sqrt ( (a^2 - b^2) / (a^2));
%! ellips.a = a;  ellips.b = b;  ellips.e = e;
%!
%! lat = rand(n, 1)*180 - 90;   % random latitudes between [-90, +90)
%! lon = rand(n, 1)*360 - 180;  % random longitudes between [-180, +180)
%! % random heights between around 20,200 km +/- 1km. 
%! h = 20200000 + rand(n, 1) *1000 - rand(n, 1) *1000;
%! %h  % debug
%!
%! coord_cart = convert_to_cartesian ([lat lon h], ellips);
%! 
%! for method=methods
%! answer_coord_geod = convert_to_geodetic (coord_cart, ellips, method);
%! answer_lat = answer_coord_geod (:, 1);
%! answer_lon = answer_coord_geod (:, 2);
%! answer_h = answer_coord_geod (:, 3);
%! 
%! %answer_coord_geod
%! %answer_lat - lat
%! %answer_lon - lon
%! %answer_h - h
%! myassert ( all(abs(answer_lat - lat) <= error_lat) );
%! myassert ( all(abs(answer_lon - lon) <= error_lon) );
%! myassert ( all(abs(answer_h - h) <= error_h) );
%! end

function [lat lon h] = ...
convert_to_geodetic_classical (x, y, z, ellips)
 
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Tolerances for steps in the 
    % iterative solution of lat and h.
    % Note that the tolerance (as used in this function) 
    % does not guarantee an error with similar magnitude.
    tol_lat = eps;
    tol_h   = eps/ellips.a;
    % eps is a system variable. It is the 
    % largest relative spacing between any two 
    % adjacent numbers in the machine's
    % floating point system. 
    % E.g., on a Celeron PC, eps = 2.2204e-16

    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Shortcuts.
    b = ellips.b;
    e = ellips.e;
    
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute lat and h
    
    % latitudinal radius
    p = sqrt(x^2 + y^2);

    if (p == 0)  
        % special case: point on either pole.
        
        if (z > 0)
            lat = +pi/2;
        elseif (z < 0)
            lat = -pi/2;
        elseif (z == 0)
            lat = 0;
        end
        h = abs(z) - b;
    else  
        % general case: solve lat and h by an iterative procedure. 
        
        % initial approximations
        h   = 0;
        lat = 0;
        N   = compute_prime_vertical_radius (lat * 180/pi, ellips);
        
        lat_0 = lat + 2*tol_lat; 
        h_0	  = h + 2*tol_h; 

        i = 0;
        while ( abs(lat - lat_0) > tol_lat || abs(h - h_0) > tol_h )
            lat_0 = lat;
            h_0   = h;

            lat = atan2( (z / p), (1 - e^2 * N / (N + h)) );
            N = compute_prime_vertical_radius (lat * 180/pi, ellips);
            h = p / cos(lat) - N;

            i = i + 1;
        end
        %display(i)  % DEBUG
    end 

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % Compute lon
    lon = atan2(y, x);
    
return;  % end of function


% The code below was given by G. C. Jones at the end of the 
% following paper:
% G. C. Jones, New solutions for the geodetic coordinate transformation,
% Journal of Geodesy, Volume 76, Issue 8, Nov 2002, Pages 437 - 446
% <http://springerlink.metapress.com/openurl.asp?genre=article&id=doi:10.1007/s00190-002-0267-4>
%
% I had problems copying and pasting the source code from the PDF file,
% so I had to replace several characters that were wrongly copied.
%
% I left the code as intact as I could. E.g., when I had to modify something,
% I kept the original lines as comment lines, instead of removing or changing
% them.

function [phi, lambda, h] = convert_to_geodetic_jones(x, y, z, ell)
%function jones(x, y, z)
%JONES Transformation of Cartesian coordinates (x,y,z)
% to geodetic coordinates (phi,lambda,h). This works
% for any (x,y,z), any a > 0 and any 0 < flat < 1
    a = ell.a;
    flat = ell.f;
%    a = 6378137;
%    flatinv = 298.257223563;
%    flat = 1/flatinv; %the flattening. (1 - e^2) = (1 - flat)^2

    rhostar = a*flat*(2 - flat); %rightmost point of evolute
    rho = sqrt(x^2 + y^2);
    if z<0, z = -z; southern = 1; else southern = 0; end
    if z > 0
        if rho > 0
            lambda = atan2(y,x);
            if rho^2 + z^2/(1 - flat)^2 >= a^2 %Region 1
                t = atan(z/(rho*(1 - flat)));
            elseif rho <= rhostar + z/(1 - flat) %Region 2
                t = atan((z*(1 - flat) + rhostar)/rho);
            else %Region 3
                t = atan(z*(1 - flat)/(rho - rhostar));
            end
            t_old = t + .1;
            while abs(t_old - t) > eps
                A = ((1 - flat)*z + rhostar*sin(t))/rho;
                f = atan (A);
                fprime = rhostar*cos(t)/(rho*(1 + A^2));
                t_old = t;
                t = t - (f - t)/(fprime - 1);
            end
            phi = atan(tan(t)/(1 - flat));
        else phi = pi/2; h = z - a*(1 - flat); lambda = 0;
        end
    else %z = 0
        phi = 0; h = rho - a;
        if rho > 0, lambda = atan2(y,x); else lambda = 0; end
    end
    h = rho*cos(phi) + z*sin(phi) - a*sqrt(1 - flat*(2 - flat)*(sin(phi))^2);
    if southern == 1, phi = -phi; end
%    if lambda < 0, lambda = lambda + 2*pi; end

%    fprintf('\n Latitude: %1.15f',phi)
%    fprintf('\n Height: %7.10f',h)
%    fprintf('\n Longitude: %1.15f \n',lambda) 
%%%%%%%%%%%%% end jones.m %%%%%%%%%%%%%

    %'hw' % debug
    idx = isnan(x) | isnan(y) | isnan(z);
    if any(idx)
        phi(idx) = NaN;
        lambda(idx) = NaN;
        h(idx) = NaN;
    end
return;

% Vectorized version of Jones.
function [phi, lambda, h] = convert_to_geodetic_jones_vec(x, y, z, ell)
%function jones(x, y, z)
%JONES Transformation of Cartesian coordinates (x,y,z)
% to geodetic coordinates (phi,lambda,h). This works
% for any (x,y,z), any a > 0 and any 0 < flat < 1
    a = ell.a;
    flat = ell.f;
%    a = 6378137;
%    flatinv = 298.257223563;
%    flat = 1/flatinv; %the flattening. (1 - e^2) = (1 - flat)^2

    phi = zeros (size(x));
    lambda = zeros (size(x));
    h = zeros (size(x));

    rhostar = a*flat*(2 - flat); %rightmost point of evolute
    rho = sqrt(x.^2 + y.^2);
    southern = (z<0); z(southern) = -z(southern);    
%    if z<0, z = -z; southern = 1; else southern = 0; end
    idx_z_gt_0 = (z > 0);
    idx_rho_gt_0 = (rho > 0);
%    if z > 0
%        if rho > 0
            lambda = atan2(y,x);
            idx_reg_1 = ( (rho.^2 + z.^2./(1 - flat)^2) >= a^2 ); %Region 1
            idx = zeros(size(x));
            t = zeros (size(x));
%            if rho^2 + z^2/(1 - flat)^2 >= a^2 %Region 1
                idx = (idx_z_gt_0 & idx_rho_gt_0 & idx_reg_1);
                t (idx) = atan(z(idx)./(rho(idx).*(1 - flat)));
%                t = atan(z/(rho*(1 - flat)));
            idx_reg_2 = ( rho <= (rhostar + z./(1 - flat)) ); %Region 2
%            elseif rho <= rhostar + z/(1 - flat) %Region 2
                idx = (idx_z_gt_0 & idx_rho_gt_0 & idx_reg_2);
                t (idx) = atan((z(idx).*(1 - flat) + rhostar)./rho(idx));
%                t = atan((z*(1 - flat) + rhostar)/rho);
            idx_reg_3 = ~ (idx_reg_1 | idx_reg_2);
%            else %Region 3
                idx = (idx_z_gt_0 & idx_rho_gt_0 & idx_reg_3);
                t (idx) = atan(z(idx).*(1 - flat)./(rho(idx) - rhostar));
%                t = atan(z*(1 - flat)/(rho - rhostar));
%            end
            t_old = t + .1;
            idx = (idx_z_gt_0 & idx_rho_gt_0 & (abs(t_old - t) > eps));
            A = zeros (size(x));
            f = zeros (size(x));
            fprime = zeros (size(x));
            while any(idx)
%            while abs(t_old - t) > eps
                A = ((1 - flat).*z + rhostar.*sin(t))./rho;
%                A = ((1 - flat)*z + rhostar*sin(t))/rho;
                f = atan (A);
                fprime = rhostar.*cos(t)./(rho.*(1 + A.^2));
%                fprime = rhostar*cos(t)/(rho*(1 + A^2));
                t_old = t;
                t(idx) = t(idx) - (f(idx) - t(idx))./(fprime(idx) - 1);
%                t = t - (f - t)/(fprime - 1);
                idx = (idx_z_gt_0 & idx_rho_gt_0 & (abs(t_old - t) > eps));
            end
            phi = zeros(size(x));
            idx = (idx_z_gt_0 & idx_rho_gt_0);
            phi(idx) = atan(tan(t(idx))./(1 - flat));
%            phi = atan(tan(t)/(1 - flat));
%        else phi = pi/2; h = z - a*(1 - flat); lambda = 0;
            idx = (idx_z_gt_0 & ~idx_rho_gt_0);
            phi(idx) = pi/2; h(idx) = z(idx) - a*(1 - flat); lambda(idx) = 0;
%        end
    idx = ~idx_z_gt_0;
%    else %z = 0
        phi(idx) = 0; h(idx) = rho(idx) - a;
%        phi = 0; h = rho - a;
        idx = (~idx_z_gt_0 & idx_rho_gt_0);
        lambda(idx) = atan2(y(idx),x(idx));
        idx = (~idx_z_gt_0 & ~idx_rho_gt_0);
        lambda(idx) = 0;
%        if rho > 0, lambda = atan2(y,x); else lambda = 0; end
%    end
    h = rho.*cos(phi) + z.*sin(phi) - a.*sqrt(1 - flat.*(2 - flat).*(sin(phi)).^2);
%    h = rho*cos(phi) + z*sin(phi) - a*sqrt(1 - flat*(2 - flat)*(sin(phi))^2);
    phi(southern) = -phi(southern);
%    if southern == 1, phi = -phi; end
%    if lambda < 0, lambda = lambda + 2*pi; end

%    fprintf('\n Latitude: %1.15f',phi)
%    fprintf('\n Height: %7.10f',h)
%    fprintf('\n Longitude: %1.15f \n',lambda) 
%%%%%%%%%%%%% end jones.m %%%%%%%%%%%%%

    %'hw' % debug
    idx = isnan(x) | isnan(y) | isnan(z);
    if any(idx)
        phi(idx) = NaN;
        lambda(idx) = NaN;
        h(idx) = NaN;
    end
return;

