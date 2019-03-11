function U = get_geopot_normal_trunc (pos_sph, ell)
%GET_GEOPOT_NORMAL_TRUNC: Return the normal geopotential (single-term truncated series), given a position in global spherical -- NOT GEODETIC -- coordinates.

% Compute the normal gravity potential by means of
% an expansion of that potential in spherical coordinates,
% TRUNCATED at degree 1 (n = 1). The error is approximately
% 350 m^2/s^2 (or 35 m, for the corresponding height) 
% on the ellipsoid.
%
% Use instead get_geopot_normal().
    if isempty(pos_sph),  U = zeros(0,1);  return;  end
    a = ell.a;
    GM = ell.GM;
    omega = ell.omega;
    J2 = ell.J2;
    
    lat_sph = pos_sph(:,1);
    r = pos_sph(:,3);
    co_lat_sph = 90 - lat_sph;

    U = (GM ./ r) .* ( 1 ...
          - (a./r).^2 .* J2 .* ((3./2) .* cos(co_lat_sph*pi/180).^2 - 1/2) ) ...
          + (omega * r.*sin(co_lat_sph*pi/180)).^2 / 2;
    %U = (GM ./ r) .* (...
    %      1 ...
    %      - (a./r).^2 .* J2 .* ((3./2) .* cos(co_lat_sph*pi/180).^2 - 1/2) ...
    %      + (omega.^2 ./ (2 .* GM)) .* r.^3 .* sin(co_lat_sph*pi/180).^2 ...
    %    );
    % Formula given in Torge, Geodesy. 3rd ed. 2001. 
    % eq. (4.46), p. 107. Adapted to avoid loss of precision 
    % in the centrifugal potential.
end

%!shared
%! n = ceil(10*rand);
%! pos_geod = rand_pt_geod(n);
%! ell = get_ellipsoid('wgs84_sph');
%! pos_cart = convert_to_cartesian(pos_geod, ell);
%! pos_sph  = convert_to_spherical(pos_cart);

%!test
%! % spherical case.
%! U  = get_geopot_sph(pos_sph, ell);
%! U2 = get_geopot_normal_trunc(pos_sph, ell);
%! 
%! g = 10;  % approximate gravity, to convert potential to length.
%! %(U2-U)/g  % DEBUG
%! myassert((U2-U)/g, 0, -sqrt(eps));

%!test
%! % When r >> a, the normal potential tends to that of a sphere,
%! % U -> GM/r + (omega^2 * p^2)/2.
%! pos_sph(:,3) = 1000*ell.a;
%! 
%! ell = get_ellipsoid('wgs84_sph');
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! ell = get_ellipsoid('wgs84');
%! U2 = get_geopot_normal_trunc (pos_sph, ell);
%! 
%! %U, U2, U2 - U  % DEBUG
%! myassert(U2, U, -1e-4)

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
%! delta = linspace(ell.b-ell.a, 0, 10);  delta(end) = [];
%! U2 = zeros(n, length(delta));
%! for i=1:length(delta)
%!     ell.b = ell.a + delta(i);
%!     ell.f = (ell.a - ell.b) / ell.a;
%!     ell.e = sqrt( (ell.a^2 - ell.b^2) / ell.a^2 );
%!     U2(:,i) = get_geopot_normal_trunc (pos_sph, ell);
%! end
%! 
%! Ue = U2 - repmat(U, 1, length(delta));
%! %delta, Ue  % DEBUG
%! %figure, plot(delta, Ue, '.-k')  % DEBUG
%! temp = interp1(delta, Ue', zeros(n, 1)', ...
%!     'linear', 'extrap');
%! Ue0 = temp(1,:)';
%! myassert(Ue0, 0, -sqrt(eps))

