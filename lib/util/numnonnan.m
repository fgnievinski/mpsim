function out = numnonnan (in, varargin)
  out = sum(~isnan(in), varargin{:});
end