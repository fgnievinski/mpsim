function [result, snr_db, carrier_error, code_error] = cell_snr_fwd (setup)
    result = cellfun2(@snr_fwd, setup);
    if (nargout < 2),  return;  end
    snr_db = cellfun2(@(resulti) resulti.snr_db, result);
    carrier_error = cellfun2(@(resulti) resulti.carrier_error, result);
    code_error = cellfun2(@(resulti) resulti.code_error, result);
end
