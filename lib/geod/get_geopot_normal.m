function geopot = get_geopot_normal (pos_sph, method, opt)
%GET_GEOPOT_NORMAL: Return the normal geopotential, given a position in global spherical -- NOT GEODETIC -- coordinates.

    if (nargin < 2) || isempty(method),  method = 'normal gravity';  end
    switch lower(method)
    case {'normal gravity, first two terms', 'normal gravity, truncated'}
        geopot = get_geopot_normal_trunc (pos_sph, opt.ell);
    case 'normal gravity, infinite series'
        geopot = get_geopot_normal_series (pos_sph, opt.ell);
    case {'normal gravity', 'normal gravity, exact', 'normal gravity, closed formula'}
        geopot = get_geopot_normal_exact (pos_sph, opt.ell);
    case 'normal gravitation, no centrifugal'
        opt.ell.omega = 0;
        geopot = get_geopot_normal_exact (pos_sph, opt.ell);
    otherwise
        error ('MATLAB:convert_to_geopot_height:unkMethod', ...
            'Method "%s" unknown.', method);
    end
end
