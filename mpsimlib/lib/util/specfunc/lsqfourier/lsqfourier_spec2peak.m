function peak = lsqfourier_spec2peak (spec, order_ind)
%LSQFOURIER_SPEC2PEAK: Extract spectral peak.

    if (nargin < 2) || isempty(order_ind),  order_ind = 1;  end
    ind = spec.order(order_ind);
    peak = structfun(@(f) f(ind), spec, 'UniformOutput',false);
    peak = rmfield(peak, {'order','order_inv'});  % (has been misleading)
    peak.ind = ind;
    if isnan(peak.power),  peak.freq = NaN;  peak.height = NaN;  end
end
