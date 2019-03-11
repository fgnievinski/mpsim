function YI1 = interp1n (x1, Y1, XI1, method, extrapval)
  %disp('hw!')  % DEBUG
  if (nargin < 4) || isempty(method),  method = 'linear';  end
  if (nargin < 5) || isempty(extrapval)
    extrapval = 'extrap';  % see doc interp1
    if any(strcmpi(method, {'nearest','linear','v5cubic'})),  extrapval = NaN;  end
  end
  if isscalar(XI1)
    YI1 = interp1 (x1, Y1, XI1, method, extrapval);
    return;
  end
  assert(isvector(x1));
  %assert(isvector(XI1));
  
  Z2 = Y1;
  [m,n] = size(Z2);
  assert(numel(x1) == m);
  [mi,ni] = size(XI1);
  if (mi==1) || (ni==1)  % isvector(XI1)
    assert((mi*ni) == n);
  else
    assert(ni == n);
  end
  % interp2 and meshgrid (in contrast with interpn and ndmesh) 
  % interpret x and y coordinates as columns and rows, resp.

  x2 = 1:n;
  y2 = x1;
  [X2, Y2] = meshgrid(x2, y2);
  %whos X2 Y2 Z2  % DEBUG

  if isvector(XI1)
    YI2 = XI1(:);
    XI2 = x2(:);
  else
    YI2 = XI1;
    XI2 = repmat(rowvec(x2), [mi 1]);
  end
  
  idx_missing = isnan(YI2);
  %idx_missing = ~isfinite(YI2);
  YI2(idx_missing) = 0;
  
  ZI2 = interp2(X2, Y2, Z2, XI2, YI2, method);    
  ZI2 = interp1n_extrap (X2, Y2, Z2, XI2, YI2, ZI2, method, extrapval);
  ZI2(idx_missing) = NaN;
  YI1 = ZI2;
end

%%
function ZI2 = interp1n_extrap (X2, Y2, Z2, XI2, YI2, ZI2, method, extrapval)
  idx_extrap = isnan(ZI2);
  if ~any(any(idx_extrap)),  return;  end
  if ~strcmp(extrapval, 'extrap'),  ZI2(idx_extrap) = extrapval;  return;  end
  idxe = idx_extrap;
  inde = find(idxe);
  for k=1:numel(inde)
    XI2e = XI2(inde(k));
    YI2e = YI2(inde(k));
    [ignore, j] = find(X2 == XI2e, 1); %#ok<ASGLU>
    Y2e = Y2(:,j);
    Z2e = Z2(:,j);
    idxn = isnan(Y2e) | isnan(Z2e);
    Y2e(idxn) = [];
    Z2e(idxn) = [];
    ZI2(inde(k)) = interp1 (Y2e, Z2e, YI2e, method, extrapval);
  end
end

%%
%!test
%! m = 1 + ceil(10*rand);
%! n = 1 + ceil(10*rand);
%! Y = rand(m,n);
%! x_max = 10*rand;
%! x = transpose(linspace(0, x_max, m));
%! xi = randint(0, x_max, n, 1);
%! yib = NaN(n,1);
%! for i=1:n
%!   yib(i) = interp1(x, Y(:,i), xi(i));
%! end
%! yia = interp1n(x, Y, xi);
%! %[yia, yib, yib-yia]  % DEBUG
%! myassert(yia, yib, -10*eps)

%!test
%! % single vector:
%! m = 1 + ceil(10*rand);
%! n = 1;
%! Y = rand(m,n);
%! x_max = 10*rand;
%! x = transpose(linspace(0, x_max, m));
%! xi = randint(0, x_max, n, 1);
%! yib = NaN(n,1);
%! for i=1:n
%!    yib(i) = interp1(x, Y(:,i), xi(i));
%! end
%! yia = interp1n(x, Y, xi);
%! %[yia, yib, yib-yia]  % DEBUG
%! myassert(yia, yib, -10*eps)

%!test
%! % NaNs:
%! m = 1 + ceil(10*rand);
%! n = 1 + ceil(10*rand);
%! Y = rand(m,n);
%! x_max = 10*rand;
%! x = transpose(linspace(0, x_max, m));
%! xi = randint(0, x_max, n, 1);
%! idx = round(randint(1, n));
%! xi(idx) = NaN;
%! yib = NaN(n,1);
%! for i=1:n
%!   yib(i) = interp1(x, Y(:,i), xi(i));
%! end
%! yia = interp1n(x, Y, xi);
%! %[yia, yib, yib-yia]  % DEBUG
%! myassert(yia, yib, -10*eps)
%! myassert(isnan(yia(idx)))
%! myassert(isnan(yib(idx)))

%!test
%! % extrapolation:
%! m = 1 + ceil(10*rand);
%! n = 1 + ceil(10*rand);
%! Y = rand(m,n);
%! x_max = 10*rand;
%! x = transpose(linspace(0, x_max, m));
%! xi = randint(x_max/2, 2*x_max, n, 1);
%! xi = linspace(x_max/2, 2*x_max, n);
%! idx = round(randint(1, n));
%! yib = NaN(n,1);
%! for i=1:n,  yib(i) = interp1(x, Y(:,i), xi(i), 'linear', 'extrap');  end
%! yia = interp1n(x, Y, xi, 'linear', 'extrap');
%! %[yia, yib, yib-yia]  % DEBUG
%! myassert(yia, yib, -10*eps)

%!test
%! % non-vector XI:
%! mi= 1 + ceil(10*rand);
%! m = 1 + ceil(10*rand);
%! n = 1 + ceil(10*rand);
%! Y = rand(m,n);
%! x_max = 10*rand;
%! x = transpose(linspace(0, x_max, m));
%! XI = randint(0, x_max, mi, n);
%! YIb = NaN(mi,n);
%! for j=1:n
%!   YIb(:,j) = interp1(x, Y(:,j), XI(:,j));
%! end
%! YIa = interp1n(x, Y, XI);
%! %[YIa, YIb, YIb-YIa]  % DEBUG
%! myassert(YIa, YIb, -10*eps)
