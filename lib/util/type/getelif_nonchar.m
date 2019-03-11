function out = getelif_nonchar (in, varargin)
    if ischar(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

