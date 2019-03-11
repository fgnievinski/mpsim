function [azim, len] = get_loxodrome_sph (pos_sph, pos_sph0, R)
%GET_LOXODROME_SPH: Return the loxodrome (its azimuth and arc-length) between two points on a sphere.

    lat = pos_sph(:,1);
    lon = pos_sph(:,2);
    lat0 = pos_sph0(:,1);
    lon0 = pos_sph0(:,2);

    lat = lat * pi/180;
    lon = lon * pi/180;
    lat0 = lat0 * pi/180;
    lon0 = lon0 * pi/180;

    func_scale = @(lat) sec(lat);
    func_y = @(lat) log(sec(lat) + tan(lat));
    %func_y = @(lat) asinh(tan(lat));  % TODO
    % ---------- Forwarded message ----------
    % From: Charles Karney <charles.karney@sri.com>
    % Date: Sat, Aug 9, 2014 at 10:44 AM
    % Subject: Re: Rhumb lines on an ellipsoid
    % To: "Felipe G. Nievinski" <fgnievinski@gmail.com>
    % ...
    % By the way, if you care about accuracy you should replace expressions
    % like
    %   log(sec(phi) + tan(phi))
    % by
    %   asinh(tan(phi))
    % which maintains relative accuracy for small phi.

    y  = func_y(lat);
    y0 = func_y(lat0);

    delta_lon = (lon - lon0);
    % obtain smallest absolute delta lon, 
    % across international day line, in necessary:
    idx = (delta_lon > pi);
      delta_lon(idx) = delta_lon(idx) - 2*pi;
    idx = (delta_lon < -pi);
      delta_lon(idx) = delta_lon(idx) + 2*pi;
    %delta_lon * 180/pi
    myassert(all(abs(delta_lon) <= pi))

    azim = atan2 (delta_lon, (y - y0));

    s = warning('off', 'MATLAB:divideByZero');
    len = R .* abs(lat - lat0) .* abs(sec(azim));
    warning(s);
    idx = (lat == lat0);
    temp = R .* abs(delta_lon) ./ func_scale(lat);
    len(idx) = temp(idx);

    azim = azim * 180/pi;

    % Reference is James Alexandre, Loxodromes: A Rhumb Way to Go, "Mathematics Magazine", Vol. 77. No. 5, Dec. 2004. <http://www.case.edu/artsci/math/alexander/mathmag349-356.pdf>.
    % I did not implement expressions for the ellipsoidal case because I'm not aware of any closed-form fomula for it. Also please note that the formulas Alexander give for the ellipsoidal case might be wrong because he ignores the difference between the two radii of curvature. He gives ds^2 = R^2 * dlat^2 + R^2*cos(lat)^2*dlon^2, whereas Hoffman-Wellenhof et at. (Navigation, 2003) gives, more correctly, ds^2 = M^2 * dlat^2 + N^2*cos(lat)^2*dlon^2.
end

%!test
%! % simple cases
%! [azim, len] = get_loxodrome_sph([0 45 0], [0 0 0], 1);
%! myassert(azim, 90);
%! myassert(len, 45*pi/180);
%! 
%! [azim, len] = get_loxodrome_sph([45 0 0], [0 0 0], 1);
%! myassert(azim, 0);
%! myassert(len, 45*pi/180);
%! 
%! [azim, len] = get_loxodrome_sph([40 45 0], [40 0 0], 1);
%! myassert(azim, 90);
%! myassert(len, 45*pi/180*cos(40*pi/180), -10*eps);
%! 
%! [azim, len] = get_loxodrome_sph([45 45 0], [45 45 0], 1);
%! myassert(azim, 0);
%! myassert(len, 0);

%!shared
%! % examples on p. 355 of Alexander's article.
%! pos_sph0 = [+(40+45/60), -(73+58/60)];  % New York
%! pos_sph = [...
%!     +(51+32/60), -(  0+10/60);  % London
%!     +( 4+32/60), -( 74+ 5/60);  % Bogota
%!     +(39+55/60), +(116+23/60);  % Beijing
%!     -(35+31/60), +(149+10/60);  % Canberra
%! ];
%! len = [5802; 4030; 14380; 16408]*1e3;
%! 
%! ell = get_ellipsoid('grs80');

%!test
%! [azim2a, len2a] = get_loxodrome_sph (pos_sph0, pos_sph, ell.a);
%! [azim2b, len2b] = get_loxodrome_sph (pos_sph0, pos_sph, ell.b);
%! 
%! %[len, len2a, len2b, len2a-len, len2b-len]./1e3  % DEBUG
%! myassert(len2b(2:end) < len(2:end) & len(2:end) < len2a(2:end))

%!test
%! [azim2, len2] = get_loxodrome_sph (pos_sph0, pos_sph, ell.a);
%! [azim3, len3] = get_loxodrome_sph (pos_sph, pos_sph0, ell.a);
%! 
%! %[azim2, azim3, azim3-azim2]
%! %[len2, len3, len3-len2]
%! myassert(len2, len3, -100*sqrt(eps))
%! myassert(abs(azim3-azim2), 180, -sqrt(eps))

