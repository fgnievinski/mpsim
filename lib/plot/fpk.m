function fpk (varargin)
  if (nargin < 1),  return;  end
  for i=1:min(2,nargin),  varargin{i} = evalin('caller', varargin{i});  end
  if (nargin < 3),  varargin{end+1} = '.k';  end
  figure, maximize(), plot(varargin{:}), grid on
end
