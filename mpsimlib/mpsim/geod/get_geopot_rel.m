function geopot_rel = get_geopot_rel (pos_sph, method, opt)
%GET_GEOPOT_REL: Return geopotential, relative to a reference surface, given a position in global spherical -- NOT GEODETIC -- coordinates.

    if (nargin < 2) || isempty(method),  method = 'normal gravity';  end
    if strstarti('spherical', method)
        pos_sph0 = [0 0 opt.ell.a];
        geopot0 = get_geopot (pos_sph0, method, opt);
    elseif strstarti('normal', method)
        geopot0 = opt.ell.U0;
    elseif strstarti('actual', method)
        geopot0 = opt.ell.W0;
    else
        error ('MATLAB:convert_to_geopot_height:unkMethod', ...
            'Method "%s" unknown.', method);
    end
    geopot = get_geopot (pos_sph, method, opt);
    geopot_rel = - (geopot - geopot0);
    % (minus because geopotential decreases upwards)
end
