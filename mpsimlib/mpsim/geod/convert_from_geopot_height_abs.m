function h = convert_from_geopot_height_abs (pos, method, opt)
%CONVERT_FROM_GEOPOT_HEIGHT_ABS: Convert from geopotential height (absolute) -- and geodetic latitude and longitude --, to ellipsoidal height.

    opt.N = NaN;  % (see convert_to_geopot_height_rel.m: if all(isnan(opt.N)) ... return;

    h = convert_from_geopot_height_rel (pos, method, opt);
end
