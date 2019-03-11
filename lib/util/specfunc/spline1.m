function [z, endcond, A] = spline1 (bx, c, x, endcond, A)
    if (nargin < 4),  endcond = [];  end
    if (nargin < 5),  A = [];  end
    myassert(isempty(endcond) || isscalar(endcond))

    n = numel(x);
    %myassert(numel(y), n);

    if isempty(A)
        [A, endcond] = splinedesign1a (bx, x(:), endcond);
    end
    myassert(size(A), [n, numel(c)]);
      
    %temp = repmat(c(:)', n, 1);
    %z = sum(A .* temp, 2);
    z = A * c(:);
    z = reshape(z, size(x));
end

