function out = nannumel (in, varargin)
  out = sum(~isnan(in), varargin{:});
end
