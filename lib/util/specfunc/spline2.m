function [z, endcond, A] = spline2 (bx, by, c, x, y, endcond, A)
    if (nargin < 6),  endcond = [];  end
    if (nargin < 7),  A = [];  end
    myassert(isempty(endcond) || isscalar(endcond))
    if (nargin == 3)
        error('matlab:spline2', ...
            'Syntax pp2 = spline2(bx, by, c) not supported.');
        % pp2 would require a ppval2 much more complex than 
        % what we need for spline2. More especifically, ppval2 
        % would need to support polynomial pieces with variable order.
    end

    n = numel(x);
    %myassert(numel(y), n);

    if isempty(A)
        [A, endcond] = splinedesign2a (bx, by, x(:), y(:), endcond);
    end
    myassert(size(A), [n, numel(c)]);
      
    %temp = repmat(c(:)', n, 1);
    %z = sum(A .* temp, 2);
    z = A * c(:);
    z = reshape(z, size(x));
end

