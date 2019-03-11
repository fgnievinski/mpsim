function [Z2, geopot2, mean_grav2, N] = convert_to_geopot_height_rel (pos_geod, method, opt)
%CONVERT_TO_GEOPOT_HEIGHT_REL: Convert to geopotential height (relative to the geoid), given geodetic coordinates.

    if isempty(method),  method = 'normal gravity, first two terms';  end
    
    opt = set_geoidal_undulation (pos_geod, opt);

    [Z1, geopot1] = convert_to_geopot_height_abs (pos_geod, method, opt);

    if all(isnan(opt.N))
        Z2 = Z1;
        temp = NaN(size(Z1));
        geopot2 = temp;
        mean_grav2 = temp;
        N = temp;
        return;
    end
    
    pos_geod0 = pos_geod;  pos_geod0(:,3) = opt.N;
    [Z0, geopot0] = convert_to_geopot_height_abs (pos_geod0, method, opt);
    Z2 = Z1 - Z0;
    geopot2 = geopot1 - geopot0;
    height2 = pos_geod(:,3) - pos_geod0(:,3);
    mean_grav2 = geopot2 ./ height2;
    N = opt.N;  if isscalar(N),  N = repmat(N, size(Z1));  end
end

%%
function opt = set_geoidal_undulation (pos_geod, opt)
    if ~isfieldempty(opt, 'N')
        if any(~isnan(opt.N))  % = ~all(isnan(opt.N))
            warning('raytracer:convert_to_geopot_height2:UsingN', ...
              ['Using constant geoidal undulation provided in "opt" structure -- \n'...
               'NOT interpolating in geoid map for each sampling point!']);
        end
        return
    end
    if ~isfield(opt, 'geoid_interp_method'),  opt.geoid_interp_method = [];  end
    opt.N = get_geoidal_undulation (pos_geod, opt.geoid, opt.geoid_interp_method);
end
