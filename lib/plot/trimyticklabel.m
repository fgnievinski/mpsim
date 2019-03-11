function trimyticklabel (ah, tail)
% discard top and/or bottom y-axis tick labels.
  if (nargin < 1) || isempty(ah),  ah = gca();  end
  if (nargin < 2) || isempty(tail),  tail = 'both';  end
  temp = cellstr(get(ah, 'YTickLabel'));
  if any(strcmpi(tail, {'both','bottom','left'})),  temp(1)   = {''};  end
  if any(strcmpi(tail, {'both','top','right'})),    temp(end) = {''};  end
  set(ah, 'YTickLabel',temp)
end
