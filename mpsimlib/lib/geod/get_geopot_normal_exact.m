function U = get_geopot_normal_exact (pos_sph, ell)
%GET_GEOPOT_NORMAL_EXACT: Return the normal geopotential (exact formula), given a position in global spherical -- NOT GEODETIC -- coordinates.

% Compute the normal gravity potential by means of a closed formula, exact
% because it's expressed in ellipsoidal-harmonic coordinates (which is
% different than geodetic coordinates).
    if isempty(pos_sph),  U = zeros(0,1);  return;  end
    if (ell.b == ell.a)
        U = get_geopot_sph (pos_sph, ell);
        return;
        % formulas below do not work for spherical case,
        % even though it is a special case of ellipsoidal case.
    end

    %%
    a = ell.a;
    b = ell.b;
    GM = ell.GM;
    omega = ell.omega;

    %%
    pos_cart = convert_to_cartesian_from_spherical (pos_sph);
    pos_ell  = convert_to_ellipsoidal_harmonic (pos_cart, ell);
    lat_red = pos_ell(:, 1) * pi/180;
    u = pos_ell(:, 3);
        
    %% Compute auxiliary quantities:
    % Linear eccentricity:
    % Formula given in Torge (Geodesy, 3rd ed.), eq. (4.3), p. 92.
    e_lin = sqrt(a^2 - b^2);
    %if (e_lin == 0),  e_lin = sqrt(eps);  end  % avoid division by zero.

    % Formula given in Torge (Geodesy, 3rd ed.), eq. (4.39), p. 106,
    % and also in Heiskanen & Moritz, eqs. (2-57) and (2-58), p. 66.
    q  = (1/2) * ( (1 + 3*(u.^2)/(e_lin^2)).*atan2(e_lin, u) - 3*(u/e_lin) );
    q0 = (1/2) * ( (1 + 3*(b.^2)/(e_lin^2)).*atan2(e_lin, b) - 3*(b/e_lin) );
    %if (q0 == 0),  q0 = eps;  end  % avoid division by zero.
    %q(q == 0) = eps;  % avoid division by zero.

    %%
    % Formula given in Torge, Geodesy. 3rd ed. 2001, eq. (4.38), p. 105,
    % and also in Heiskanen & Moritz, eq. (2-62), p. 67.
    qr = q./q0;
    U = (GM ./ e_lin) * atan2(e_lin, u) ...
        + ((omega^2)/2) * a^2 * qr .* (sin(lat_red).^2 - 1/3) ...
        + ((omega^2)/2) * (u.^2 + e_lin^2) .* cos(lat_red).^2;
    % trying to avoi loss of precision (apparently unnecessary)
    %U = (GM ./ e_lin) * atan2(e_lin, u) ...
    %    + (1/2)*( (omega*a)^2 * (q/q0) .* (sin(lat_red).^2 - 1/3) ) ...
    %    + (1/2)*( (omega*u.*cos(lat_red)).^2 + (omega*e_lin*cos(lat_red)).^2);
end


%!shared
%! %rand('seed', 0)  % HEY!
%! ell = get_ellipsoid('wgs84');
%! n = ceil(10*rand);
%! pos_geod = rand_pt_geod(n);
%! pos_geod(:,3) = 1000*pos_geod(:,3);  % exagerate heights
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_sph  = convert_to_spherical (pos_cart);

%!test
%! % Points on the ellipsoid should all have normal gravity potential...
%! pos_geod(:,3) = 0;
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_sph  = convert_to_spherical (pos_cart);
%! 
%! U = get_geopot_normal_exact (pos_sph, ell);
%! 
%! % ... constant:
%! %U - U(1)
%! myassert (U, U(1), -10*eps^(1/3));
%! 
%! % ... equal to U_0, calculated by a simpler formula:
%! e_lin = sqrt(ell.a^2 - ell.b^2);
%! U0 = ell.GM/e_lin * atan2(e_lin, ell.b) + (ell.omega^2/3)*ell.a^2;
%! % Torge, eq. (4.40).
%! %U - U0  % DEBUG
%! myassert (U, U0, -10*eps^(1/3));
%! 
%! % ... equal to U_0 (given):
%! %U - ell.U0  % DEBUG
%! myassert (U, ell.U0, -ell.U0_tol);
%! 
%! % Please note that, "With the exception of the surface of the level 
%! % ellipsoid, spheropotential surfaces deviate from ellipsoids and 
%! % are NOT parallel to each other." (Torge, Geodesy, p. 111, 2nd ed).
%! %    In other words, U(h=const.<>0) <> const.

%!test
%! % When r >> a, the normal potential tends to that of a sphere,
%! % U -> GM/r + (omega^2 * p^2)/2.
%! pos_sph(:,3) = 1000*ell.a;
%! 
%! ell = get_ellipsoid('wgs84_sph');
%! %ell.omega = 0;
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! ell = get_ellipsoid('wgs84');
%! %ell.omega = 0;
%! U2 = get_geopot_normal_exact (pos_sph, ell);
%! 
%! %U, U2  % DEBUG
%! %U2 - U  % DEBUG
%! tol = 1e-3 * 10;  % []=m^2/s^2, = 1 mm * 10 m/s^2
%! myassert(U2, U, -tol)

%!#test
%! % When ell.b -> ell.a, 
%! % get_geopot_normal() -> get_geopot_sph().
%! 
%! ell = get_ellipsoid('wgs84_sph');
%! %ell.omega = 0;
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! ell = get_ellipsoid('wgs84');
%! %ell.omega = 0;
%! delta0 = get_J2 (ell.a, 0, ell.omega, ell.GM);  % see get_J2.
%! delta = linspace(ell.b-ell.a, 0, 10);
%! delta(end) = [];  % remove zero
%! delta(end+1) = delta0;  
%! delta = sort(delta);
%! U2 = zeros(n, length(delta));
%! for i=1:length(delta)
%!     ell.b = ell.a + delta(i);
%!     ell.f = (ell.a - ell.b) / ell.a;
%!     ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
%!     U2(:,i) = get_geopot_normal_exact(pos_sph, ell);
%! end
%! 
%! Ue = U2 - repmat(U, 1, length(delta));
%! %delta, Ue  % DEBUG
%! %figure, plot(delta, Ue, '.-k')  % DEBUG
%! temp = interp1(delta, Ue', zeros(n, 1)', ...
%!     'linear', 'extrap');
%! %Ue0 = temp(1,:)';
%! %myassert(Ue0, 0, -sqrt(eps))
%! Ue0 = Ue(:, delta==delta0);
%! %[min(abs(Ue), [], 2), Ue0]  % DEBUG
%! myassert(min(abs(Ue), [], 2), abs(Ue0))
%! 
%! % The discrepancy between get_geopot_normal and 
%! % get_geopot_sph decreases as b->a, 
%! % reaches a minimum at delta0=a-b at which 
%! % J2 is zero, then starts to increase again, 
%! % with negative sign.
%! % 
%! % Please note that get_geopot_normal does NOT use J2,
%! % but I believe the diverging behaviour as b->a in 
%! % get_geopot_normal and get_J2 have the same root problem,
%! % which I don't understand.

%!test
%! % ellipsoid degenerates onto a sphere:
%! % avoid division by zero
%! lastwarn('');
%! U = get_geopot_normal_exact (pos_sph, ell);
%! [msgstr, msgid] = lastwarn;
%! myassert(~strcmp(msgid, 'MATLAB:divideByZero'))

%!test
%! U  = get_geopot_normal_exact(pos_sph, ell);
%! Ub = get_geopot_normal_series(pos_sph, ell);
%! %[U, Ub, Ub-U]
%! myassert (U, Ub, -10*eps^(1/3))

%!#test
%! % TODO
%! % The gradient of the normal gravity potential 
%! % equals the normal gravity acceleration vector.
%! 
%! % Compare numerical to analytical partial derivatives
%! % forming the gradient or acceleration.
%! % Hofmann-Wellenhof & Moriz provide the analytical form.
%! 
%! % Also compare the norm of those vectors; 
%! % on the ellipsoid (only!), compare it to Somigliana's
%! % formula for gravity magnitude.

