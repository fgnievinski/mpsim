function result = cell_snr_fwd_fringe_visib (result, varargin)
    result = cellfun2(@(resulti)snr_fwd_fringe_visib(resulti, varargin{:}), result);
    if (nargout < 2),  return;  end
end
