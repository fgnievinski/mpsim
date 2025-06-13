function pos_cart = convert_from_ellipsoidal_harmonic (pos_ell, ell)
%CONVERT_FROM_ELLIPSOIDAL_HARMONIC: Convert from ellipsoidal-harmonic coordinates, to global Cartesian coordinates.

    lat_red = pos_ell(:,1)*pi/180;
    lon     = pos_ell(:,2)*pi/180;
    u       = pos_ell(:,3);

    e_lin = sqrt(ell.a^2 - ell.b^2);

    temp = sqrt(u.^2 + e_lin^2) .* cos(lat_red);
    X = temp .* cos(lon);
    Y = temp .* sin(lon);
    Z = u .* sin(lat_red);

    pos_cart = [X Y Z];

    % Formulas as per Hofmann-Hellenhof & Moritz, Physical Geodesy,
    % 1st ed., eq. (6-6), p. 240.
end

%!test
%! ell = get_ellipsoid('fake');
%! n = ceil(10*rand);
%! pos_geod = rand_pt_geod(n);
%! pos_geod(:,3) = 1000*pos_geod(:,3);  % exagerate heights
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_cart2 = convert_from_ellipsoidal_harmonic(convert_to_ellipsoidal_harmonic(...
%!     pos_cart, ell), ell);
%! %pos_cart, pos_cart2, pos_cart2-pos_cart  % DEBUG
%! myassert (pos_cart2, pos_cart, -sqrt(eps));

