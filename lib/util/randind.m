function ind = randind (n, m, opt)
  if (nargin < 2) || isempty(m),  m = n;  end
  if (nargin < 3),  opt = [];  end
  x = rand(n,1);
  if (m == 1)
    ind = argmin(x);
    return;
  end
  ind = argsort(x);
  if (m==n),  return;  end
  ind = ind(1:m);
  if ~strcmpi(opt, 'unique'),  return;  end
  %ind(end-1:end) = ind(1:2);  % DEBUG
  while true
    indu = unique(ind);
    mu = numel(indu);
    if (mu == m),  return;  end
    ind = indu;
    ind(mu+1:m) = randind (n, m-mu, opt);
  end
end
