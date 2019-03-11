function out = getelif_numeric (in, varargin)
    if ~isnumeric(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

