function out = midrange (in, dim)
%MIDRANGE  Mid-range value.
% 
% See also: MIDRANGER

  if (nargin < 2),  dim = [];  end
  %opt = {[], dim};  % WRONG!
  if isempty(dim),  opt = {};  else  opt = {[], dim};  end
  out = ( max(in, opt{:}) + min(in, opt{:}) ) ./ 2;
end

%!test
%! myassert(midrange(1:10), 5.5);
%! midrange(1:10);
%! midrange(1:10, 1);
%! midrange(1:10, 2);


