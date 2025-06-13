function [lat, lon] = proj_polar_stereo_inv (proj, x, y)
    lat_0  = proj.origin(1); 
    lon_0  = proj.origin(2); 
    lat_ts = proj.mapparallels;
    k_0    = proj.scalefactor;
    ell.a  = proj.geoid(1);
    ell.e  = proj.geoid(2);
    proj_polar_stereo_chk (lat_ts, lat_0, k_0, ...
        proj.nparallels, proj.mapparallels);

    lat_0  = lat_0 * pi/180;
    lon_0  = lon_0 * pi/180;
    lat_ts = lat_ts * pi/180;

    lat_0_original = lat_0;
    if (lat_0_original < 0)
        %disp('hw!')
        lat_ts = - lat_ts;
        lon_0  = - lon_0;
        lat_0  = - lat_0;
        x      = - x;
        y      = - y;
    end

    delta_lon = atan2(x, -y);
    %delta_lon*180/pi  % DEBUG
    
    if (lat_0_original < 0) 
        lon = lon_0 + delta_lon;
    else
        lon = lon_0 - delta_lon;
    end 
        lon = lon_0 + delta_lon;
    rho = -y ./ cos(delta_lon);
      t_c = proj_polar_stereo_get_t (lat_ts, ell);
      m_c = proj_polar_stereo_get_m (lat_ts, ell);
    t = rho .* t_c ./ (ell.a .* m_c);
    lat = pi/2 - 2*atan(t);
    if (ell.e ~= 0)
        %disp('hw!')
        f = @(lat) proj_polar_stereo_get_t (lat, ell);
        % refine approximate lat above:
        lat = inv_func2 (f, t, lat, sqrt(eps(lat)));
    end     

    if (lat_0_original < 0)
        lat = - lat;
        lon = - lon;
    end

    lat = lat * 180/pi;
    lon = lon * 180/pi;
end

%!test
%! % Numerical example given by Snyder (p. 315)
%! % (polar aspect with known lat_ts not at the pole).
%!  
%! a = 6378388;  % m
%! e = sqrt(0.00672267);
%! b = a * sqrt(1 - e^2);
%! f = (a - b) / a;
%! 
%! proj = defaultm('stereo');
%! proj.geoid = [a e];
%! proj.origin = [-90, -100];
%! proj.mapparallels = -71;
%! proj.nparallels = 1;
%! proj.scalefactor = [];
%! 
%! lat_true = -75;
%! lon_true = +150;
%! x_true = -1540033.6;  % m
%! x_tol     =        0.05;
%! y_true = -560526.4;  % m
%! y_tol     =       0.05;
%! k_true = 1638869.6 / (6378388.0 * 0.2596346);
%! k_tol     = 0.00000005;
%! lat_tol = nthroot(eps, 3);
%! lon_tol = nthroot(eps, 3);
%! 
%! [x, y] = proj_polar_stereo (proj, lat_true, lon_true);
%! [lat, lon] = proj_polar_stereo_inv (proj, x_true, y_true);
%! 
%! %[lat, lat_true, lat-lat_true]
%! %[mod(lon,360), mod(lon_true,360), mod(lon,360)-mod(lon_true,360)]
%! myassert (lat, lat_true, -lat_tol);
%! myassert (mod(lon,360), mod(lon_true,360), -lon_tol);

%!test
%! % Numerical example given by Snyder (p. 314)
%! % (polar aspect with known k_0).
%!  
%! a = 6378388;  % m
%! e = sqrt(0.00672267);
%! b = a * sqrt(1 - e^2);
%! f = (a - b) / a;
%! 
%! proj = defaultm('stereo');
%! proj.geoid = [a e];
%! proj.origin = [-90, -100];
%! proj.mapparallels = [];
%! proj.nparallels = [];
%! proj.scalefactor = 0.994;
%! 
%! lat_true = -75;
%! lon_true = +150;
%! x_true = -1573645.4;  % m
%! x_tol     =        0.5;
%! y_true = -572760.1;  % m
%! y_tol     =       0.5;
%! k_true = 1674638.5 / (6378388.0 * 0.2596346);
%! k_tol     = 0.0000005;
%! lat_tol = nthroot(eps, 3);
%! lon_tol = nthroot(eps, 3);
%! 
%! [lat, lon] = proj_polar_stereo_inv (proj, x_true, y_true);
%! 
%! %[lat, lat_true, lat-lat_true]
%! %[mod(lon,360), mod(lon_true,360), mod(lon,360)-mod(lon_true,360)]
%! myassert (lat, lat_true, -lat_tol);
%! myassert (mod(lon,360), mod(lon_true,360), -lon_tol);

%!test
%! a = 6378388;  % m
%! e = 0;
%! b = a * sqrt(1 - e^2);
%! f = (a - b) / a;
%! 
%! proj = defaultm('stereo');
%! proj.geoid = [a e];
%! proj.origin = [-90, -100];
%! proj.mapparallels = -71;
%! proj.nparallels = 1;
%! proj.scalefactor = [];
%! 
%! n = round(10*rand);
%! x_true = randint(-1e3, +1e3, n, 1);
%! y_true = randint(-1e3, +1e3, n, 1);
%! x_tol = nthroot(eps, 4);
%! y_tol = nthroot(eps, 4);
%! 
%! [lat, lon] = proj_polar_stereo_inv (proj, x_true, y_true);
%! [x, y] = proj_polar_stereo (proj, lat, lon);
%! 
%! %[x, x_true, x-x_true]
%! %[y, y_true, y-y_true]
%! myassert (x, x_true, -x_tol);
%! myassert (y, y_true, -y_tol);
