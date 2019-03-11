function result = cell_snr_fwd_fringe_dev (result, varargin)
    result = cellfun2(@(resulti)snr_fwd_fringe_dev(resulti, varargin{:}), result);
    if (nargout < 2),  return;  end
end
