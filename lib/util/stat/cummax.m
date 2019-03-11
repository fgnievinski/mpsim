function y = cummax(x)
% Find the cumulative maximum of row vector x:
%
%     y(k) equals max(x(1:k)) for k in [1 N]
%
% where N is numel(x).
siz = size(x);
x = x(:)';
y = cummaxaux(x);
y = reshape(y, siz);

function y = cummaxaux(x)
% Construct a matrix whose k-th row contains x(1,1:k) followed
% by N-k zeros.
A = tril(x(ones(numel(x),1),:));

% Find the largest value in each column of A; return result in a row vector.
y = max(A,[],2)';
