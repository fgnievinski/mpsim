function out = getelif (in, cond, varargin)
    if ~cond(in),  out = in;  return;  end
    out = getel (in, varargin{:});
end

