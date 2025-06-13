function varargout = nanscatter (x, y, s, varargin) 
  idx = isnan(x) | isnan(y);
  if ~isscalar(s),  idx = idx | isnan(s);  end
  if (nargin > 3) && ~isscalar(varargin{1})
    idx = idx | isnan(varargin{1});
    varargin{1}(idx) = [];
  end
  x(idx) = [];
  y(idx) = [];
  if ~isscalar(s),  s(idx) = [];  end
  [varargout{1:nargout}] = scatter (x, y, s, varargin{:});
end
