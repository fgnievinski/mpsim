function out = midranger (in, prc, dim)
%MIDRANGER  Mid-range value, robustified against outliers.
% 
% See also: MIDRANGE

  if (nargin < 2),  prc = 10;  end
  if (nargin < 3),  dim = [];  end
  %opt = {[], dim};  % WRONG!
  if isempty(dim),  opt = {};  else  opt = {[], dim};  end
  prc_lo = prc/2;
  prc_hi = 100-prc/2;
  lo = prctile(in, prc_lo, opt{:});
  hi = prctile(in, prc_hi, opt{:});
  out = (lo+hi)./2;
end

%!test
%! myassert(midranger([1:100 -1000]), 50, eps());

%!test
%! % is it just the median?
%! in = rand(100,1);
%! out1 = midranger(in);
%! out2 = median(in);
%! [out1, out2, out2-out1]  % DEBUG
%! %myassert(out1, out2);
%! % close, but different.
