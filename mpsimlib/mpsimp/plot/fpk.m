function fpk (varargin)
  if (nargin < 1),  return;  end
  varargin_orig = varargin;
  for i=1:min(2,nargin),  varargin{i} = evalin('caller', varargin{i});  end
  if (nargin < 3),  varargin{end+1} = '.k';  end
  figure, maximize(), plot(varargin{:}), grid on
  xlabel(varargin_orig{1}, 'Interpreter','none')
  if (nargin > 1),  ylabel(varargin_orig{2}, 'Interpreter','none');  end
end
