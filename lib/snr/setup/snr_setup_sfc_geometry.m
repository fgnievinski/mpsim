function sfc = snr_setup_sfc_geometry (pos_ant, pos_sfc0, sett_sfc)
    temp = getfields(sett_sfc, {'slope','aspect','azim','along','across'}, true);
    if any(structfun(@(f) ~isempty(f) && (f~=0), temp))
        if isequal(sett_sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_horiz)
            warning('snr:snr_setup_sfc_geom:badFnc', ...
                'Non-empty surface tilting angles detected; setting up tilted surface.');
            sett_sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
        %elseif isequal(sett_sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_dem)
        %    warning('snr:snr_setup_sfc_geom:badFnc', ...
        %        'Non-empty surface tilting angles detected; setting up DEM surface.');
        %else  % if isequal(sett_sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_tilted)
        end
    end

    sfc = sett_sfc.fnc_snr_setup_sfc_geometry (pos_ant, pos_sfc0, sett_sfc);
    sfc.fnc_snr_setup_sfc_geometry = sett_sfc.fnc_snr_setup_sfc_geometry;
    
    sfc.height_std = sett_sfc.height_std;
    if isempty(sfc.height_std),  sfc.height_std = 0;  end
end
