function geopot = get_geopot (pos_sph, method, opt)
%GET_GEOPOT: Return geopotential (Earth's gravity potential), given a position in global spherical -- NOT GEODETIC -- coordinates.

    if (nargin < 2) || isempty(method) ...
    || strncmpi(method, 'normal', 6)
        geopot = get_geopot_normal (pos_sph, method, opt);
        return;
    end
    switch lower(method)
    case 'spherical earth'
        geopot = get_geopot_sph (pos_sph, opt.ell, [], false);
    case 'spherical earth, no centrifugal'
        geopot = get_geopot_sph (pos_sph, opt.ell, true, false);
    case 'actual gravity'
        if ~isfield(opt, 'degree_max'),  opt.degree_max = [];  end
        %disp(opt.degree_max)  % DEBUG
        if ~isfieldempty(opt, 'geopot_coeff'),  opt.geopot = opt.geopot_coeff;  end
        geopot = get_geopot_actual (pos_sph, opt.ell, opt.geopot, opt.degree_max);
        % minus because geopotential decreases upwards.    
    case {'actual gravity, truncated'}
        if isfield(opt, 'degree_max') && ~isempty(opt.degree_max)
            warning('raytracer:convert_to_geopot_height1:ignoring', ...
                'Ignoring input opt.degree_max.');
        end
        opt.degree_max = 2;
        method = 'actual gravity';
        geopot = get_geopot (pos_sph, method, opt);
    otherwise
        error ('MATLAB:convert_to_geopot_height:unkMethod', ...
            'Method "%s" unknown.', method);
    end
end
