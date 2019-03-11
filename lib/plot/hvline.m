function [lineHandlesH, lineHandlesV] = hvline (varargin)
  lineHandlesH = hline(varargin{:});
  lineHandlesV = vline(varargin{:});
  if (nargout==0),  clear lineHandlesH lineHandlesV;  end
end
