function Y = genlogitinv (X, A, K, B, v, Q, M)
    if (nargin < 2) || isempty(A),  A = 0;  end
    if (nargin < 3) || isempty(K),  K = 1;  end
    if (nargin < 4) || isempty(B),  B = 1;  end
    if (nargin < 5) || isempty(v),  v = 1;  end
    if (nargin < 6) || isempty(Q),  Q = 1;  end
    if (nargin < 7) || isempty(M),  M = 0;  end

    Y = A + (K-A)./( 1+Q.*exp(-B.*(X-M)) ).^(1/v);
end
% <https://en.wikipedia.org/wiki/Generalised_logistic_function>
% A: the lower asymptote
% K: the upper asymptote
% B: the growth rate
% v>0 : affects near which asymptote maximum growth occurs.
% Q: depends on the value Y(0)
% M: the time of maximum growth if Q=v

