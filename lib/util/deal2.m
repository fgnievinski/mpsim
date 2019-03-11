function varargout = deal2 (in, dim)
    if (nargin < 2),  dim = 1;  end
    switch dim
    case 1
        f = @(i) in(:,i);
    case 2
        f = @(i) in(i,:);
    end
    varargout = arrayfun(f, 1:nargout, 'UniformOutput',false);
end

%!test
%! in = [1 2 3 4];
%! [a, b, c, d] = deal2(in);
%! assert(a == 1)
%! assert(b == 2)
%! assert(c == 3)
%! assert(d == 4)

