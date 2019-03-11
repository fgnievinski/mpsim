function sfc = snr_setup_sfc (sett_sfc, frequency, ref)
    sfc0 = snr_setup_sfc_material (sett_sfc, frequency);
    sfc1 = snr_setup_sfc_origin (sfc0.thickness, ref, sett_sfc);
    sfc2 = snr_setup_sfc_geometry (ref.pos_ant, sfc1.pos_sfc0, sett_sfc);
    sfc = structmerge(sfc0, sfc1, sfc2);
    sfc.pre0 = sfc0;
    sfc.pre1 = sfc1;
    sfc.pre2 = sfc2;
end
