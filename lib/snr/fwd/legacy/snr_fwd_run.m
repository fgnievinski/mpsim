% (this is a legacy interface, kept for backwards compatibility;
%  we recommend using instead the modern version: snr_fwd.)
function [snr_db, extra, carrier_error, code_error] = snr_fwd_run (sat, sfc, ant, ref, opt, bias, pre)
    if (nargin < 6) || isempty(bias)
        sett_bias = snr_bias_settings();
        bias = snr_setup_bias (sett_bias, sat, opt);
    end
    setup = struct('sat',sat, 'sfc',sfc, 'ant',ant, 'ref',ref, 'opt',opt, 'bias',bias);
    if (nargin > 6),  setup.pre = pre;  end
    [result, snr_db, carrier_error, code_error] = snr_fwd (setup);
    extra = result;
end

