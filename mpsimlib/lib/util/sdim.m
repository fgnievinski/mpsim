function ind = sdim (x, k)
    if isempty(x),  ind = [];  return;  end
    if (nargin < 2) || isempty(k),  k = 1;  end
    siz = size(x);
    siz(end+1) = 1;
    idx = (siz == 1);
    ind = find(idx, k);
end

%!test
%! assert(sdim(ones(1,2)) == 1)
%! assert(sdim(ones(2,1)) == 2)
%! assert(sdim(ones(2,2)) == 3)
%! assert(sdim(ones(2,2,2)) == 4)
%! assert(sdim(ones(2,1,2)) == 2)
%! assert(isempty(sdim(ones(0,0))))
