function h = easyhist2 (x, y, n, l)
  if (nargin < 3) || isempty(n),  n = 50;  end
  if (nargin < 4) || isempty(l),  l = '95';  end
  if ischar(l), l = {l};  end
  if isscalar(l),  l = [l l];  end
  if isscalar(n),  n = [n n];  end
  [m, xl, yl] = hist2(x, y, n(1), n(2), l{1}, l{2});
  imagesc(xl, yl, m);
  set(gca(), 'YDir','normal')
end