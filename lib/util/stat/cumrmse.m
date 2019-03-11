function out = cumrmse (in, dim)
    if (nargin < 2) || isempty(dim),  dim = 1;  end
    [n1,n2] = size(in);
    switch dim
    case 1
        den = repmat((1:n1)', [1 n2]);
    case 2
        den = repmat((1:n2),  [n1 1]);
    end
    num = cumsum(in.^2, dim);
    %whos num den  % DEBUG
    %num, den  %#ok<NOPRT> % DEBUG
    out = sqrt(num./den);
end

%!test
%! in = [...
%!   1 2
%!   3 4
%!   5 6
%! ];
%! 
%! out1 = [...
%!   rmse([1]),     rmse([2])
%!   rmse([1 3]),   rmse([2 4])
%!   rmse([1 3 5]), rmse([2 4 6])
%! ];
%! out2 = [...
%!   rmse([1]), rmse([1 2])
%!   rmse([3]), rmse([3 4])
%!   rmse([5]), rmse([5 6])
%! ];
%! 
%! out1b = cumrmse (in, 1);
%! out2b = cumrmse (in, 2);
%! 
%! %out1b-out1
%! %out2b-out2
%! myassert(out1b, out1)
%! myassert(out2b, out2)
