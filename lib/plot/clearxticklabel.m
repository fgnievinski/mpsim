function clearxticklabel (ah)
% discard x-axis tick labels.
  if (nargin < 1) || isempty(ah),  ah = gca();  end
  set(ah, 'XTickLabel',[])
end
