function out = anynan (in, dim)
% ANYNAN  Detect presence of any NaN, row- or column-wisely.
% 
% See also: ANY, ISNAN.

  if (nargin < 2) || isempty(dim),  dim = finddim(in);  end
  out = any(isnan(in), dim);
end

%!test
%! in = [...
%!     1 1 1
%!     1 1 NaN
%!     1 NaN 1
%!     1 1 1
%! ];
%! out1 = [...
%!     1 
%! ];
%! myassert(anynan(in), anynan(in,1))
%! myassert(anynan(in,1), [false true true])
%! myassert(anynan(in,2), [false true true false]')
%! myassert(~anynan(in(:,1)))
%! myassert( anynan(in(:,2)))
%! myassert(~anynan(in(1,:)))
%! myassert( anynan(in(2,:)))
