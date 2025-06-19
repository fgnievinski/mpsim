% Lambert conformal conic projection.
function [x, y] = proj_lambert (info, lat, lon)
% Formulas given in the following publication:
%   Snyder, John Parr (1987), Map projections--a working manual
%   Washington. 383 p. (U.S. Geological Survey professional paper 1395)
%
% All equations are in p. 106-107 of that publication.
% For the main equations I give the eq. number as used in the 
% original publication.

    % I use the same data structure for map information
    % as used by MAtlab's Mapping Toolbox:
    R = info.geoid(1);
    lat_0 = info.origin(1);
    lon_0 = info.origin(2);
    lat_1 = info.mapparallels(1);
    if (length(info.mapparallels) > 1)
        lat_2 = info.mapparallels(2);
    else
        lat_2 = NaN;
    end

    if (abs(info.geoid(2)) > eps)  % excentricity
        error ('I support only spheres, not ellipsoids.');
    end
   
    
    % "if (lon - lon_0) exceeds the range +/-180 degrees,
    % 360 degrees should be added or subtracted":
    temp = lon - lon_0;
    idx  = temp >  180;
    lon(idx) = lon(idx) - 360;
    idx  = temp < -180;
    lon(idx) = lon(idx) + 360;

    
    %%    
    lat = lat * pi/180;
    lon = lon * pi/180;
    
    lon_0 = lon_0 * pi/180;
    lat_0 = lat_0 * pi/180;
    lat_1 = lat_1 * pi/180;
    lat_2 = lat_2 * pi/180;

    
    %%
    % Constants common to all points:
    if (isnan(lat_2) | (lat_1 == lat_2))
        n = sin(lat_1);
    else
        % two standard parallels
        n =   log( cos(lat_1) / cos(lat_2) ) ...
            / log( tan(pi/4 + lat_2/2) / tan(pi/4 + lat_1/2) );  % (15-3)
    end
    F = cos(lat_1) * ( tan(pi/4 + lat_1/2)^n ) / n;  % (15-2)

    rho_0 = R .* F ./ ( tan(pi/4 + lat_0/2).^n );  % (15-1a)


    %% 
    % For each point:    
    rho   = R .* F ./ ( tan(pi/4 + lat  /2).^n );  % (15-1)
    
    theta = n .* (lon - lon_0);  % (14-4)
    
    x =         rho .* sin(theta);  % (14-1)
    y = rho_0 - rho .* cos(theta);  % (14-2)
   
    if isfield(info, 'northing'),  y = y + info.northing;  end
    if isfield(info, 'easting'),   x = x + info.easting;  end
return;


%!test
%! % Numerical example given by Snyder (p. 295)
%! 
%! info.geoid = [1, 0];        % a, e
%! info.origin(1) =  23;       % lat_0
%! info.origin(2) = -96;       % lon_0
%! info.mapparallels(1) = 33;  % lat_1
%! info.mapparallels(2) = 45;  % lat_2
%! 
%! lat = 35;
%! lon = -75;
%! x_correct = 0.2966785;
%! y_correct = 0.2462112;
%! err       = 0.00000005;
%! 
%! [x, y] = proj_lambert (info, lat, lon);
%! 
%! myassert (x, x_correct, -err);
%! myassert (y, y_correct, -err);
%! 

%!test
%! % Test with only one parallel.
%! 
%! info.geoid = [1, 0];        % a, e
%! info.origin(1) =  23;       % lat_0
%! info.origin(2) = -96;       % lon_0
%! info.mapparallels(1) = 33;  % lat_1
%! 
%! % Point at origin (trivial solution):
%! lat = 23;
%! lon = -96;
%! x_correct = 0;
%! y_correct = 0;
%! err       = eps;
%! 
%! [x, y] = proj_lambert (info, lat, lon);
%! 
%! myassert (x, x_correct, -err);
%! myassert (y, y_correct, -err);

%!test
%! % Test with only one parallel, non-unity radius.
%! 
%! info.geoid = [6366707, 0];        % a, e
%! info.origin(1) =  0;       % lat_0
%! info.origin(2) = -95;       % lon_0
%! info.mapparallels(1) = 25;  % lat_1
%! 
%! % Point at origin (trivial solution):
%! lat = 0;
%! lon = -95;
%! x_correct = 0;
%! y_correct = 0;
%! err       = eps;
%! 
%! [x, y] = proj_lambert (info, lat, lon);
%! 
%! myassert (x, x_correct, -err);
%! myassert (y, y_correct, -err);

%!test
%! % One single parallel or two equal parallels
%! % should yield the same answer.
%! 
%! info.geoid = [6366707, 0];        % a, e
%! info.origin(1) =  0;       % lat_0
%! info.origin(2) = -95;       % lon_0
%! info.mapparallels = [25];  % lat_1
%! 
%! [x1, y1] = proj_lambert (info, 0, -95);
%! info.mapparallels = [25 25];  % [lat_1 lat_2]
%! [x2, y2] = proj_lambert (info, 0, -95);
%! 
%! myassert (x1, x2, -eps);
%! myassert (y1, y2, -eps);

%!test
%! % NaN in, NaN out.
%! 
%! info.geoid = [6366707, 0];        % a, e
%! info.origin(1) =  0;       % lat_0
%! info.origin(2) = -95;       % lon_0
%! info.mapparallels = [25];  % lat_1
%! 
%! [x1, y1] = proj_lambert (info, NaN, NaN);
%! 
%! myassert (isnan(x1));
%! myassert (isnan(y1));

