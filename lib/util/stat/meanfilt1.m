function y = meanfilt1 (x, n, dim)
  if (nargin < 2) || isempty(n),  n = 3;  end
  if (nargin < 3) || isempty(dim),  dim = finddim(x);  end
  b = ones(1,n)./n;
  y = filter(b,1,x,[],dim);
end
