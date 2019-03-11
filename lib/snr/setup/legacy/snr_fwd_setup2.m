function [sfc, ant, ref, opt] = snr_fwd_setup2 (sett_old, sett, sfc, ant, ref, opt)
    setup_old = struct('sfc',sfc, 'ant',ant, 'ref',ref, 'opt',opt);
    setup = snr_setup2 (sett_old, sett, setup_old);
    %sat = setup.sat;
    sfc = setup.sfc;
    ant = setup.ant;
    ref = setup.ref;
    opt = setup.opt;
end
