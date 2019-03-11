function is_visible = snr_fwd_visibility_horiz (...
setup, geom, type) %#ok<INUSL>
    switch lower(type)
    case 'direct'
        is_visible = [];
    case 'reflection'
        %op = @gt;
        op = @ge;  % works at the horizon.
        is_visible = op(geom.direct.dir.local_ant.elev, 0);
        %is_visible = op(geom.reflection.sat_dir.sfc.elev, 0);  it'd be the same.
    end
end

