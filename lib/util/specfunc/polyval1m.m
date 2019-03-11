function [z, A] = polyval1m (C, x, A)
    if (nargin < 3),  A = [];  end
    if isscalar(x),  x = repmat(x, [size(C,1) 1]);  end
    myassert (isvector(x));
    siz = size(x);
    x = x(:);

    if isempty(A),  A = polydesign1a (x, C(1,:));  end

    if isequal(size(C), size(A))
        z = sum(C.*A, 2);
    elseif isvector(C) && (numel(C) == size(A,2))
        z = A * C(:);
        %z = sum(bsxfun(@times, C, A), 2);
    else
        error('MATLAB:polyval1m:badSize', 'Bad size of input matrices.');
    end
    z = reshape(z, siz);
end
