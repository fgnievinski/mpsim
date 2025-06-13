function [snr_db, extra, carrier_error, code_error] = snr_po_run1 (sat, sfc, ant, ref, opt, pre)
    setup = struct('sat',sat, 'sfc',sfc, 'ant',ant, 'ref',ref, 'opt',opt);
    if (nargin > 5),  setup.pre = pre;  end
    [result, snr_db, carrier_error, code_error] = snr_po1 (setup);
    result.composite.phasor = result.phasor_composite;
    result.multipath.phasor = result.phasor_composite;
    result.direct.phasor = result.phasor_direct;
    result.net.phasor = result.phasor_reflected;
    extra = result;
end


