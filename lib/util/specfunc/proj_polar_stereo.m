% Polar stereographic projection.
function [x, y, k] = proj_polar_stereo (proj, lat, lon)
% Formulas given in the following publication:
%   Snyder, John Parr (1987), Map projections--a working manual
%   Washington. 383 p. (U.S. Geological Survey professional paper 1395)
%
% All equations are in p. 161 of that publication.
% For the main equations I give the eq. number as used in the 
% original publication.

    %%
    % I use the same data structure for map information
    % as used by MAtlab's Mapping Toolbox:
    lat_0  = proj.origin(1); 
    lon_0  = proj.origin(2); 
    lat_ts = proj.mapparallels;
    k_0    = proj.scalefactor;
    ell.a  = proj.geoid(1);
    ell.e  = proj.geoid(2);
    proj_polar_stereo_chk (lat_ts, lat_0, k_0, ...
        proj.nparallels, proj.mapparallels);

    %%
    lat_0  = lat_0 * pi/180;
    lon_0  = lon_0 * pi/180;
    lat_ts = lat_ts * pi/180;

    lon = lon * pi/180;
    lat = lat * pi/180;

    %%
    % "For the south polar aspect, the equations for the north polar aspect
    % may be used, but the signs of x, y, lat_ts, lat, lon, and lon_0
    % must be reversed to be used in the equations." (p. 161).
    lat_0_original = lat_0;
    if ( lat_0_original < 0 )
        %'hw'  % debug
        lat_ts = - lat_ts;
        lat    = - lat;
        lon    = - lon;
        lon_0  = - lon_0;
        lat_0  = - lat_0;
    end

    
    %%%%%%%%%%

    
    %%
    if ~isempty (lat_ts)
        rho = get_rho(lat, lat_ts, ell);
    else
        %'hw'  % debug
        rho = get_rho2(lat, k_0, ell);
    end
    %rho  % debug
    
    % calculate projected coordinates:
    delta_lon = lon - lon_0;
    %delta_lon*180/pi  % DEBUG
    x =   rho .* sin(delta_lon);
    y = - rho .* cos(delta_lon);

    % calculate scale factor (optional):
    if (nargout > 1)
        a = ell.a;
        m = proj_polar_stereo_get_m (lat, ell);
        % calculate scale factor at point (lon, lat):
        k = rho ./ (a .* m);  % (21-32)

        % note: to get k at the pole, should use k_0 instead.
    end

    %atan2(x, -y)*180/pi  % DEBUG
    if ( lat_0_original < 0 )
        x = - x;
        y = - y;
    end
    
return;

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
%! lat = -75;
%! lon = +150;
%! x_correct = -1540033.6;  % m
%! x_tol     =        0.05;
%! y_correct = -560526.4;  % m
%! y_tol     =       0.05;
%! k_correct = 1638869.6 / (6378388.0 * 0.2596346);
%! k_tol     = 0.00000005;
%! 
%! [x, y, k] = proj_polar_stereo (proj, lat, lon);
%! %[x2, y2] = projfwd (proj, lat, lon)
%! 
%! myassert (x, x_correct, -x_tol);
%! myassert (y, y_correct, -y_tol);
%! myassert (k, k_correct, -k_tol);

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
%! lat = -75;
%! lon = +150;
%! x_correct = -1573645.4;  % m
%! x_tol     =        0.5;
%! y_correct = -572760.1;  % m
%! y_tol     =       0.5;
%! k_correct = 1674638.5 / (6378388.0 * 0.2596346);
%! k_tol     = 0.0000005;
%! 
%! [x, y, k] = proj_polar_stereo (proj, lat, lon);
%! %[x2, y2] = projfwd (proj, lat, lon)
%! 
%! myassert (x, x_correct, -x_tol);
%! myassert (y, y_correct, -y_tol);
%! myassert (k, k_correct, -k_tol);


%%%%%%%%%%%%%%%%%%%%%%%%%    
% return rho at latitude phi given latitude phi_c along 
% which scale is true (i.e., along wich scale factor equals 1).
function rho = get_rho(phi, phi_c, ell)
    a = ell.a;

    t   = proj_polar_stereo_get_t (phi, ell);
    t_c = proj_polar_stereo_get_t (phi_c, ell);
    m_c = proj_polar_stereo_get_m (phi_c, ell);

    rho = a .* m_c .* t ./ t_c;  % (21-34)

return;
  
%%%%%%%%%%%%%%%%%%%%%%%%%    
% return rho at latitude phi given scale factor at origin
function rho = get_rho2(phi, k_0, ell)
    a = ell.a;
    e = ell.e;

    t = proj_polar_stereo_get_t (phi, ell);
    rho = 2 * a * k_0 * t / ( (1+e)^(1+e) * (1-e)^(1-e) )^0.5;  % (21-33)

return;

