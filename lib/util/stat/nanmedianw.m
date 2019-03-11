function [ym, ws, n, mws] = nanmedianw (y, w, dim, ignore_nans)
%NANMEDIANW  Weighted median, ignoring NaNs.
  if (nargin < 2),  w = [];  end
  if (nargin < 3),  dim = [];  end
  if (nargin < 4),  ignore_nans = [];  end
  [dim, ignore_nans, ignore, w] = nanstdur_aux (y, ...
   dim, ignore_nans, [],     w); %#ok<ASGLU>
  
  if (dim == 2),  y = y.';  w = w.';  end
  
  [ym, ws, n] = nanmedianwcol (y, w, ignore_nans);
  mws = ws ./ n;
  
  if (dim == 2),  ym = ym.';  ws = ws.';  n = n.';  mws = mws.';  end
end

%%
function [ym, ws, n] = nanmedianwcol (y, w, ignore_nans)
  m   = size(y,2);
  ym  = NaN(1,m);
  ws  = NaN(1,m);
   n  = NaN(1,m);
  for j=1:m
    [ym(j), ws(j), n(j)] = nanmedianwvec (y(:,j), w(:,j), ignore_nans);
  end
  %TODO: nanmedianwcol w/ no for-loop.
end

%%
function [ym, ws, n] = nanmedianwvec (y, w, ignore_nans)
  if ignore_nans,  idx = isnan(y) | isnan(w);  y(idx) = [];  w(idx) = [];  end
  n = numel(y);
  %ws = sum(w, dim);  wm = ws ./ n;
  wm = median(w);  ws = wm .* n;
  switch n
  case 0,  ym = NaN;
  case 1,  ym = y;
  case 2,  ym = mean(y);
  otherwise,  ym = nanmedianwvecaux (y, w, ws, n);
  end
end

%%
function ym = nanmedianwvecaux (y, w, ws, n)
  nw = w ./ ws;
  [y, indo] = sort(y);
  nw = nw(indo);
  cw = cumsum(nw);
  %indm = argmin(abs(wc - 1/2));
  indm = find((cw - 1/2)>0, 1);
  if isodd(n),  ym = y(indm);  return;  end
  %indm2 = indm + [0, +1];  % WRONG!
  indm2 = indm + [-1, 0];
  indm2(1) = max(1, indm2(1));
  indm2(2) = min(n, indm2(2));
  ym = mean(y(indm2));
end

%!test
%! nanmedianw([], []);
%! nanmedianw(pi, 1);
%! nanmedianw([1;2], [1;2]);

%!test
%! for n=0:10
%!   y = rand(n,1);
%!   w = ones(n,1);
%!   ymw = nanmedianw(y, w);
%!   ym  = nanmedian (y);
%!   %[n, ym, ymw, ymw-ym]  % DEBUG
%!   myassert(ymw, ym)
%! end

%!test
%! for m=0:5
%! for n=0:5
%!   y = rand(m,n);
%!   w = ones(m,n);
%!   ymw1 = nanmedianw(y, w, 1);
%!   ymw2 = nanmedianw(y, w, 2);
%!   ym1  = nanmedian (y, 1);
%!   ym2  = nanmedian (y, 2);
%!   %ymw1, ym1
%!   %ymw2, ym2
%!   myassert(ymw1, ym1)
%!   myassert(ymw2, ym2)
%! end
%! end
