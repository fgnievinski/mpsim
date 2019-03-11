function out = numnan (in, varargin)
  out = sum(isnan(in), varargin{:});
end
