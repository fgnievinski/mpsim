function varargout = plotposnrf (answers, fz, p, in_color, vs_sine, field, field2, lab2, tick2)
  if (nargin < 2) || isempty(fz),  fz = 0:1:10;  end
  if (nargin < 3) || isempty(p),  p = 2;  end
  if (nargin < 4),  in_color = [];  end
  if (nargin < 5),  vs_sine = [];  end
  if (nargin < 6),  field = [];  end
  if (nargin < 7),  field2 = [];  end
  if (nargin < 8),  lab2 = [];  end
  if (nargin < 9),  tick2 = [];  end

  %TODO: call get_multipath_modulation.
  f = @(answer, field) ( get_power(answer.map.(field)+answer.direct.phasor) - get_power(answer.direct.phasor) - get_power(answer.map.(field)) )./ ( 2 * abs(answer.direct.phasor) .* abs(answer.net.phasor) );
  if (p ~= 2)
    f2 = @(x) abs(x).^(p/2).*sign(x);
    f = @(answer) f2(f(answer));
  end
  if (p==1),  lab = 'Composite magnitude (V/V)';  elseif (p==2), lab = 'Composite power (W/W)';  else lab = ''; end
  lab = [lab sprintf('\n(detrended, normalized)')];
  
  [varargout{1:min(nargout,2)}] = plotpovse (answers, f, lab, fz, in_color, vs_sine, field, field2, lab2, tick2);
  
  if (nargout > 2),  varargout{3} = fz;  end
end
