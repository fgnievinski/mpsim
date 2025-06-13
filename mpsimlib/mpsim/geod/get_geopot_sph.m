function U = get_geopot_sph (pos_sph, ell, add_centrifugal, warn)
%GET_GEOPOT_SPH: Return geopotential of spherical Earth, given a position in global spherical -- NOT GEODETIC -- coordinates.

    if isempty(pos_sph),  U = zeros(0,1);  return;  end
    if (nargin < 3),  add_centrifugal = true;  end
    if (nargin < 4),  warn = true;  end
    if (ell.b ~= ell.a) && warn
        warning('MATLAB:notSph', 'Function defined for spherical case only.');
    end

    a = ell.a;
    GM = ell.GM;
    r = pos_sph(:,3);
    U = GM./r;

    if ~add_centrifugal,  return;  end

    lat_sph = pos_sph(:,1);
    omega = ell.omega;
    p = r .* cos(lat_sph*pi/180);
    U = U + (omega^2 * p.^2)./2;
end

%!test
%! % get_geopot_sph ()
%! lasterror('reset')
%! warning('off', 'MATLAB:notSph')

%!test
%! get_geopot_sph ([1 1 1], get_ellipsoid('wgs84'));

%!test
%! % get_geopot_sph ()
%! s = lasterror;
%! myassert(isempty(s.identifier))
%! %myassert(s.identifier, 'MATLAB:notSph');
%! [msg, id] = lastwarn;
%! myassert(strcmp(id, 'MATLAB:notSph'))
%! warning('on', 'MATLAB:notSph')


%!shared
%! ell = get_ellipsoid('wgs84');
%! ell.b = ell.a;  ell.f = 0;  ell.e = 0;
%! n = 1 + ceil(10*rand);  % min 2
%! pos_geod = rand_pt_geod (n);
%! pos_cart = convert_to_cartesian(pos_geod, ell);
%! pos_sph = convert_to_spherical(pos_cart);

%!test
%! % test gravitation potential:
%! % (decreases linearly with r)
%! ell.omega = 0;
%! U = get_geopot_sph (pos_sph, ell);
%! %sortrows([U-min(U), pos_sph(:,3)-min(pos_sph(:,3))])  % DEBUG
%! temp = corrcoef(U, pos_sph(:,3));
%! c = temp(2,1);
%! myassert(c, -1, -10*sqrt(eps));

%!test
%! % test centrifugal potential:
%! % (increases linearly with p^2)
%! ell.GM = 0;
%! p_sq = sum(pos_cart(:,1:2).^2, 2);
%! %p_sq2 = (pos_sph(:,3) .* cos(pos_sph(:,1)*pi/180) ).^2;
%! %p_sq2 - p_sq  % DEBUG
%! U = get_geopot_sph (pos_sph, ell);
%! %sortrows([p_sq, U])  % DEBUG
%! temp = corrcoef(U, p_sq);
%! c = temp(2,1);
%! %c - +1
%! myassert(c, +1, -10*sqrt(eps));


%!test
%! % Points on the sphere have all normal gravity potential
%! % constant, WHEN centrifugal potential is null.
%! pos_sph(:,3) = mean(pos_sph(:,3));
%! ell.omega = 0;
%! 
%! U = get_geopot_sph (pos_sph, ell);
%! 
%! %U - U(1)
%! myassert (U - U(1), 0, -10*sqrt(eps));

