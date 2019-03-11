function [snr_db, extra, carrier_error, code_error] = snr_fwd_run (sat, sfc, ant, ref, opt, pre)
    setup = struct('sat',sat, 'sfc',sfc, 'ant',ant, 'ref',ref, 'opt',opt);
    if (nargin > 5),  setup.pre = pre;  end
    [result, snr_db, carrier_error, code_error] = snr_fwd (setup);
    extra = result;
end

