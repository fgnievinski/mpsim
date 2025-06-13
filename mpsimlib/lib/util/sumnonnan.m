function out = sumnonnan (in, dim)
% SUMNONNAN  Number of non-NaN values.
% 
% See also: ANY, ISNAN.

  if (nargin < 2) || isempty(dim),  dim = finddim(in);  end
  out = sum(~isnan(in), dim);
end
