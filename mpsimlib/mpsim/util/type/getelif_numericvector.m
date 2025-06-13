function out = getelif_numericvector (in, varargin)
    if ~isnumeric(in) || ~isvector(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

