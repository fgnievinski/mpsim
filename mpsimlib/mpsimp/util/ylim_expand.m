function yl = ylim_expand (prc, ah)
  if (nargin < 1) || isempty(prc),  prc = 15;  end
  if (nargin < 2) || isempty(ah),  ah = gca();  end
  yl = ylim(ah);
  if strcmp(get(gca(), 'YScale'), 'log'),  return;  end
  yl = yl + [-1,+1].*diff(yl)*(1/2)*prc/100;
  ylim(ah, yl);
  if (nargout < 1),  clear yl;  end
end
