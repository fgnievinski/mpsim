function out = getelif_nonscalar_nonempty (in, varargin)
    if isempty(in) || isscalar(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

