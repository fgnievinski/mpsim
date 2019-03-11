function out = getelif_nonstruct (in, varargin)
    if isstruct(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

