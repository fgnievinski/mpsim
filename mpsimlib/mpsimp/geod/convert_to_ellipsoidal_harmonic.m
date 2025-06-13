function pos_ell = convert_to_ellipsoidal_harmonic (pos_cart, ell)
%CONVERT_TO_ELLIPSOIDAL_HARMONIC: Convert to ellipsoidal-harmonic coordinates, given global Cartesian coordinates.

    if isempty(pos_cart),  pos_ell = pos_cart;  return;  end
    % Please not ellipsoidal-harmonic coordinates are different than
    % ellipsoidal-geodetic coordinates (as given by convert_to_geodetic).
    % This system is described in Heiskanen & Moritz (Physical Geodesy), 
    % p. 39-41, and also in Torge (Geodesy, 3rd ed.), p. 104 and 95, 
    % and in Holfmann-Wellenfor & Moritz (Physical Geodesy), p.240, 
    % eq. (6-6) to (6-10).
    
    a = ell.a;
    b = ell.b;
    e_lin = sqrt(a^2 - b^2);

    X = pos_cart(:, 1);
    Y = pos_cart(:, 2);
    Z = pos_cart(:, 3);
    
    temp = X.^2 + Y.^2 + Z.^2 - e_lin^2;
    u = sqrt( temp .* (1/2) .* (1 + sqrt(1 + 4*e_lin^2*Z.^2./temp.^2)) );
    lat_red = atan2(Z.*sqrt(u.^2 + e_lin^2), u.*sqrt(X.^2 + Y.^2))*180/pi;
    lon = atan2(Y, X)*180/pi;
    
    pos_ell = [lat_red, lon, u];
end


%!shared
%! ell = get_ellipsoid('wgs84');
%! n = ceil(10*rand);
%! pos_geod = rand_pt_geod(n);
%! pos_geod(:,3) = 1000*pos_geod(:,3);  % exagerate heights
%! pos_cart = convert_to_cartesian (pos_geod, ell);

%!test
%! % "For linear eccentricity equal to zero, the [ellipsoidal]-system
%! % with lat_red = 90 degrees - co_lat_sph and u = r degenerates into the
%! % system of spherical coordinates" (Torge, bottom of p. 104).
%! 
%! ell.b = ell.a;  ell.f = 0;  ell.e = 0;
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! 
%! pos_ell = convert_to_ellipsoidal_harmonic (pos_cart, ell);
%! pos_sph = convert_to_spherical (pos_cart);
%! 
%! lat_sph = pos_sph (:, 1);
%! lat_ell = pos_ell (:, 1);
%! % convert_to_spherical() returns directly lat_sph instead of co_lat_sph.
%! % therefore Torge's statement (see above) can be recast directly 
%! % in terms of lat_sph:
%! myassert (all( abs(lat_sph - lat_ell) < sqrt(eps)) );
%! 
%! lon_sph = pos_sph (:, 2);
%! lon_ell = pos_ell (:, 2);
%! myassert (all( abs(lon_sph - lon_ell) < sqrt(eps)) );
%! 
%! %keyboard
%! r = pos_sph (:, 3);
%! u = pos_ell (:, 3);
%! myassert (all( abs(r - u) < sqrt(eps)) );

%!test
%! % Ellipsoidal latitude is different than spherical latitude.
%! % when the ellipsoid is not a sphere
%! % (this is obvious, but once I used the latter when I should 
%! % have used the former).
%! 
%! pos_ell = convert_to_ellipsoidal_harmonic (pos_cart, ell);
%! pos_sph = convert_to_spherical (pos_cart);
%! 
%! lat_sph = pos_sph (:, 1);
%! lat_ell = pos_ell (:, 1);
%! myassert (all( ~isequal(lat_sph, lat_ell) ));
%! 
%! lon_sph = pos_sph (:, 2);
%! lon_ell = pos_ell (:, 2);
%! myassert (all( abs(lon_sph - lon_ell) < sqrt(eps)) );

%!test
%! % Ellipsoidal latitude is different than geodetic latitude.
%! % (added just for completeness of this test suite)
%! 
%! pos_ell = convert_to_ellipsoidal_harmonic (pos_cart, ell);
%! 
%! lat_geod = pos_geod (:, 1);
%! lat_ell = pos_ell (:, 1);
%! myassert (all( ~isequal(lat_geod, lat_ell) ));
%! 
%! lon_geod = pos_geod (:, 2);
%! lon_ell = pos_ell (:, 2);
%! myassert (all( abs(lon_geod - lon_ell) < sqrt(eps)) );

%!test
%! % Torge's formulation is not optimal.
%! function pos_ell = convert_to_ellipsoidal_harmonic2 (pos_cart, ell)
%!     a = ell.a;  b = ell.b;
%! 
%!     lat_geod = pos_geod(:,1);
%!     lon      = pos_geod(:,2);
%! 
%!     lat_red = atan( (b/a)*tan(lat_geod*pi/180) )*180/pi;
%!     % Torge, eq. (4.11a), p. 95.
%!     
%!     pos_cart = convert_to_cartesian (pos_geod, ell);
%!     Z = pos_cart(:,3);
%!     u = Z ./ sin(lat_red*pi/180);
%!
%!     pos_ell = [lat_red, lon, u];
%! end
%! function pos_ell = convert_to_ellipsoidal_harmonic3 (pos_geod, ell)
%!     a = ell.a;  b = ell.b;
%! 
%!     X = pos_cart(:, 1);
%!     Y = pos_cart(:, 2);
%!     Z = pos_cart(:, 3);
%!     
%!     p = sqrt(X.^2 + Y.^2);
%!     %lat_red = atan2(a.*Z, b.*p)*180/pi;
%!     lat_red = atan2(Z./b, p./a)*180/pi;
%!     % Formula derived from two given in Torge, eq. (4.10), p. 95,
%!     %     p = a * cos(lat_red)
%!     %     Z = b * sin(lat_red)
%!     
%!     u = Z ./ sin(lat_red*pi/180);
%!     % Formula given in Torge, eq. (4.35), p. 104.
%!
%!     lon = atan2(Y, X)*180/pi;
%! 
%!     pos_ell = [lat_red, lon, u];
%! end
%! 
%! %ell = get_ellipsoid('fake');
%! n = 25;
%! h = linspace(0, 15e3, n)';
%! pos_geod = repmat([45 0 0], n, 1);
%! pos_geod(:,3) = h;
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! 
%! pos_ell  = convert_to_ellipsoidal_harmonic  (pos_cart, ell);
%! pos_ell2 = convert_to_ellipsoidal_harmonic2 (pos_cart, ell);
%! pos_ell3 = convert_to_ellipsoidal_harmonic3 (pos_geod, ell);
%! 
%! pos_cartb  = convert_from_ellipsoidal_harmonic (pos_ell, ell);
%! pos_cartb2 = convert_from_ellipsoidal_harmonic (pos_ell2, ell);
%! pos_cartb3 = convert_from_ellipsoidal_harmonic (pos_ell3, ell);
%! 
%! ec  = norm_all(pos_cartb  - pos_cart);
%! ec2 = norm_all(pos_cartb2 - pos_cart);
%! ec3 = norm_all(pos_cartb3 - pos_cart);
%! 
%! %figure
%! %subplot(3,1,1)
%! %  plot(h, ec, '.-k')
%! %  set(gca, 'XLim', [min(h), max(h)])
%! %  title('Implementation 1')
%! %subplot(3,1,2)
%! %  plot(h, ec2, '.-k')
%! %  set(gca, 'XLim', [min(h), max(h)])
%! %  ylabel('3D error in cartesian coordiantes (meters)')
%! %  title('Implementation 2')
%! %subplot(3,1,3)
%! %  plot(h, ec3, '.-k')
%! %  set(gca, 'XLim', [min(h), max(h)])
%! %  xlabel('Height (meters)')
%! %  title('Implementation 3')
%! 
%! myassert(ec, 0, -sqrt(eps))

%!test
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_cart2 = convert_from_ellipsoidal_harmonic(convert_to_ellipsoidal_harmonic(...
%!     pos_cart, ell), ell);
%! %pos_cart, pos_cart2, pos_cart2-pos_cart  % DEBUG
%! myassert (pos_cart2, pos_cart, -sqrt(eps));

