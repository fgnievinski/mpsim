function [m, s] = eigsym_aux (A, n, plotit)
  if (nargin < 3) || isempty(plotit),  plotit = false;  end
  if (n == 1),  m = 1;  s = NaN;  return;  end
  [ignore, s] = eigsym (A, n, [], true, true); %#ok<ASGLU>
  s(s == 0) = [];
  temp = log10(abs(s));
  temp = gradient(gradient(temp));
  temp = abs(temp);
  m = find(temp > (median(temp)+3*std_robust(temp)), 1, 'last');
  m = m - 1;
  if ~plotit,  return;  end
  figure, semilogy(abs(s(1:min(150,end))), 'o-k'), hold on, semilogy(m, abs(s(m)), 'or', 'MarkerFaceColor','r')
  return;
  figure, plot(temp, 'o-k')
  hline(median(temp))
  hline(median(temp)+std_robust(temp))
end
