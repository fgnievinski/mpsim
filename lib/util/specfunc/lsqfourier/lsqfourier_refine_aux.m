function [peak, fit, resid] = lsqfourier_refine_aux (...
peak, fit, resid, jacob, colname)
    N = jacob'*jacob;
    u = jacob'*resid;
    x = - N \ u;
    y = jacob*x;
    
    X0 = struct2mat(getfields(peak, colname));
    X = X0 + x;
    peak = num2struct(rowvec(X), colname, 2);
    
    if ~isfield(peak, 'freq'),  peak.freq = [];  end
    polname = colname(strstart('poly', colname));
    peak.poly = struct2mat(getfields(peak, polname));
    
    if (nargout < 2),  return;  end
    resid_orig = resid;
    resid = resid_orig + y;
    %resid = resid - y;  % WRONG!
    %assert(nanrmse(resid) <= nanrmse(resid_orig))
    if (nanrmse(resid) > nanrmse(resid_orig))
        warning('matlab:lsqfourier:refine:bad', ...
          'Deterioration upon refinment detected.');
    end
    fit_orig = fit;
    fit = fit_orig + y;
    %fit = fit - y;  % WRONG!
    %fit = eval_sinusoid (peak.amplitude, peak.phase, peak.freq, sine);  % WRONG! ignores poly.
end
