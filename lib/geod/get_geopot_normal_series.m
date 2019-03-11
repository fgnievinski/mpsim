function [U, n] = get_geopot_normal_series (pos_sph, ell, n_max)
%GET_GEOPOT_NORMAL_SERIES: Return the normal geopotential (spherical series expansion), given a position in global spherical -- NOT GEODETIC -- coordinates.

    if isempty(pos_sph),  U = zeros(0,1);  return;  end
    if (nargin < 3),  n_max = Inf;  end

    a = ell.a;
    e = ell.e;
    GM = ell.GM;
    omega = ell.omega;
    if isfieldempty(ell, 'J2'),  ell.J2 = get_J2 (ell.a, ell.b, ell.omega, ell.GM);  end     
    J2 = ell.J2;
    
    %%
    lat_sph = pos_sph(:,1);  lon = pos_sph(:,2);  r = pos_sph(:,3);
    p = r .* cos(lat_sph*pi/180);
    co_lat_sph = 90 - lat_sph;

    %%
    n = 1;
    summ = zeros(size(pos_sph, 1), 1);
    %terms = [];
    while true
        J2n = (-1)^(n+1)  ...
              * ( 3*e^(2*n) / ((2*n + 1)*(2*n + 3)) ) ...
              * ( 1 - n + 5*n*J2/e^2 );
        % Formula modified from the one given in Heiskanen & Moritz, 
        % eq. (2-92) and (2-92'), p. 73. It was modified to be expressed
        % in terms of J2, noting that a^2/E^2 = a^2/e_lin^2 = 1/e^2.
        % Also given on p. 130 of Moritz (2000) Geodetic Reference 
        % System 1980. Journal of Geodesy, 74: 128-133.

        P2n = get_legendre_poly (2*n, cos(co_lat_sph*pi/180));

        term = (a./r).^(2*n) .* J2n .* P2n;
        %terms = [term, terms];

        summ = summ + term;

        if ((n+1) > n_max) || all( abs(term.*GM./r) < eps )  % for all points
            break;
        end

        n = n + 1;
    end
    %n  % DEBUG
    %sum(terms, 2) - summ  % DEBUG

    %%
    %keyboard
    U = GM./r .* (1 - summ) + (omega^2 * p.^2)/2;
    % It's also given in HEiskanen & Moritz, eq. previous to (2-92),
    % without the centrifugal potential.
end

%!shared
%! %rand('seed', 0)  % HEY!!!
%! ell = get_ellipsoid('wgs84');
%! n = ceil(10*rand);
%! pos_geod = rand_pt_geod(n);
%! %pos_geod(:,3) = abs(pos_geod(:,3));
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_sph  = convert_to_spherical (pos_cart);

%!test
%! % compare to truncated series implementation:
%! U  = get_geopot_normal_trunc  (pos_sph, ell);
%! [U2, n] = get_geopot_normal_series (pos_sph, ell, 1);
%! %n, [U2 - U]  % DEBUG
%! myassert(n, 1);
%! myassert(U2, U, -10*sqrt(eps));

%!test
%! % When r >> a, the normal potential tends to that of a sphere,
%! % U -> GM/r + (omega^2 * p^2)/2.
%! pos_sph(:,3) = 1000*ell.a;
%! 
%! ell = get_ellipsoid('wgs84_sph');
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! ell = get_ellipsoid('wgs84');
%! U2 = get_geopot_normal_series (pos_sph, ell);
%! 
%! %U, U2, U2 - U  % DEBUG
%! myassert(U2, U, -1e-4)

%!test
%! % Points on the ellipsoid should all have normal gravity potential...
%! pos_geod(:,3) = 0;
%! pos_cart = convert_to_cartesian (pos_geod, ell);
%! pos_sph  = convert_to_spherical (pos_cart);
%! 
%! U = get_geopot_normal_series (pos_sph, ell);
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

%!#test
%! % When ell.b -> ell.a, 
%! % get_geopot_normal() -> get_geopot_sph().
%! 
%! ell = get_ellipsoid('wgs84_sph');
%! ell.omega = 0;
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! ell = get_ellipsoid('wgs84');
%! ell.omega = 0;
%! delta = linspace(ell.b-ell.a, 0, 10);  delta(end) = [];
%! U2 = zeros(n, length(delta));
%! for i=1:length(delta)
%!     ell.b = ell.a + delta(i);
%!     ell.f = (ell.a - ell.b) / ell.a;
%!     ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
%!     U2(:,i) = get_geopot_normal_series (pos_sph, ell);
%! end
%! 
%! Ue = U2 - repmat(U, 1, length(delta));
%! delta, Ue  % DEBUG
%! figure, plot(delta, Ue, '.-k')  % DEBUG
%! temp = interp1(delta, Ue', zeros(n, 1)', ...
%!     'linear', 'extrap');
%! Ue0 = temp(1,:)';
%! myassert(Ue0, 0, -sqrt(eps))

