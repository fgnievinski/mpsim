function is_visible = snr_fwd_visibility_tilted (...
setup, geom, type) %#ok<INUSL>
    switch lower(type)
    case 'direct'
        is_visible = [];
    case 'reflection'
        %op = @gt;
        op = @ge;  % works at exact grazing incidence.
        %is_visible = op(geom.direct.dir.local_ant.elev, 0);  % WRONG!
        is_visible = op(geom.reflection.sat_dir.sfc.elev, 0);
        % (checking the scattered grazing angle angle would be equivalent, 
        %  because of specular reflection equal-angle condition.)
        %is_visible = op(geom.reflection.delay, 0);  % EXPERIMENTAL (seems equivalent)
        if isfield(geom.reflection.extra, 'is_line_facing_plane') ...
        && isfield(geom.reflection.extra, 'is_degenerate')            
            % (snr_fwd_geometry_reflection_tilted was not optimized.)
            is_visible = is_visible ...
                &  geom.reflection.extra.is_line_facing_plane ...
                & ~geom.reflection.extra.is_degenerate;
        end
    end
end

