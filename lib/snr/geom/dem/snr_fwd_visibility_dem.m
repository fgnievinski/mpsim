function is_visible = snr_fwd_visibility_dem (...
setup, geom, type)
    switch lower(type)
    case 'direct'
        is_visible = [];
        setup.opt.occlusion.type = 'direct';
        is_visible = snr_fwd_occlusion (setup, geom, is_visible);
    case 'reflection'
        is_visible = snr_fwd_visibility_tilted (setup, geom, type);
        is_visible = is_visible & none(isnan(geom.reflection.pos.local.cart),2);
        setup.opt.occlusion.type = 'reflection';
        is_visible = snr_fwd_occlusion (setup, geom, is_visible);
    end
end

