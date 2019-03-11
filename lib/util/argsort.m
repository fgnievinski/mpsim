function [c, b] = argsort (a, varargin)
    %disp('hw!');
    [b, c] = sort(a, varargin{:});
end

%!test
%! % argsort()
%! test invsort