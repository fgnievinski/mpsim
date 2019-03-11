function [a, b, c] = find (X, k, pos)
    s = warning('off', 'MATLAB:conversionToLogical');
    
    switch nargin
    case 1
        in = {full(logical(X))};
    case 2
        in = {full(logical(X)), full(k)};
    case 3
        in = {full(logical(X)), full(k), full(k)};
    end

    switch nargout
    case {0, 1}
        a = find (in{:});
    case 2
        [a, b] = find (in{:});
    case 3
        [a, b, c] = find (in{:});
    end    
    
    warning(s);
end

%!test

