function [dir_sfc, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup, geom) %#ok<INUSD,INUSL>
    sfc = setup.sfc;
    if ~isfield(sfc, 'optimizeit'),  sfc.optimizeit = [];  end
    if ~isfield(sfc, 'economic'),  sfc.economic = [];  end
    [dir_sfc, optimizeit, economic] = snr_fwd_direction_local2 (...
        length(dir_local.elev), dir_local, ...
        sfc.rot, sfc.dir_nrml, sfc.aspect, sfc.slope, [], sfc.optimizeit, sfc.economic);
end

