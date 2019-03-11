function out = setel_ifnumeric (in, varargin)
    if ~isnumeric(in),  out = in;  return;  end
    out = setel (in, varargin{:});
end

