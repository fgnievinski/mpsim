function sfc = snr_setup_sfc_geometry_horiz (pos_ant, pos_sfc0, sett_sfc)
    if (nargin < 2) || isempty(pos_sfc0),  pos_sfc0 = [0 0 0];  end
    if (nargin < 3),  sett_sfc = struct();  end
    if isfield(sett_sfc, 'slope') && ~isempty(sett_sfc.slope) ...
    && (sett_sfc.slope ~= 0) && ~isnan(sett_sfc.slope)
        warning('snr:snr_setup_sfc_geometry_horiz:slope', ...
            'Ignoring non-zero slope.');
    end
    sfc.pos_sfc0 = pos_sfc0;
    sfc.dir_nrml = [0 0 1];
    sfc.height_ant_sfc = pos_ant(:,3) - pos_sfc0(:,3);
    idx = (sfc.height_ant_sfc < 0);
    if any(idx)
        warning('snr:snr_setup_sfc_geometry_horiz:negH', ...
          ['Negative effective height detected (%g m); ', ...
           'discarding negative sign.'], sfc.height_ant_sfc(find(idx, 1)));
        sfc.height_ant_sfc(idx) = abs(sfc.height_ant_sfc(idx));
    end
    
    sfc.snr_fwd_geometry_reflection = @snr_fwd_geometry_reflection_horiz;
    sfc.snr_fwd_direction_local2sfc = @snr_fwd_direction_local2sfc_horiz;
    sfc.snr_fwd_visibility          = @snr_fwd_visibility_horiz;
    sfc.snr_fwd_divergence          = @snr_fwd_divergence_horiz;
    sfc.snr_fwd_geometry_sfc_height = @snr_fwd_geometry_sfc_height_horiz;
    sfc.num_specular_max = 1;
end

