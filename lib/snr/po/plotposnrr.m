function varargout = plotposnrr (answers, fz, p, in_color, vs_sine)
  if (nargin < 2) || isempty(fz),  fz = 0:1:10;  end
  if (nargin < 3) || isempty(p),  p = 2;  end
  if (nargin < 4),  in_color = [];  end
  if (nargin < 5),  vs_sine = [];  end

  field = 'rphasor';
  field2 = 'radius';
  lab2 = sprintf('Radius\n(m)');
  tick2 = NaN;
  
  [varargout{1:min(nargout,2)}] = plotposnrf (answers, fz, p, in_color, vs_sine, field, field2, lab2, tick2);
end
