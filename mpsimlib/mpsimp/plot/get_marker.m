function m = get_marker (ls, ind)
  if (nargin < 1),  ls = '';  end
  m  = {'+','o','*','.','x','s','d','^','v','>','<','p','h'};
  if (nargin < 1),  return;  end
  m = strcat(m, ls);
  if (nargin < 2),  return;  end
  m = m(wrap_ind(ind, numel(m)));
  if isscalar(m),  m = m{1};  end
end

