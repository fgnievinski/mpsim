function y = snr_po_accum (x, ind, ind_inv, mask)
    y = getel(cumsum(x(ind(:))), ind_inv);
    if (nargin < 4),  return;  end
    y(~mask) = NaN;
end
