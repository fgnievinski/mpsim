function [X,s,A2] = pinv2(A,varargin)
%PINV   Pseudoinverse.
%   X = PINV(A) produces a matrix X of the same dimensions
%   as A' so that A*X*A = A, X*A*X = X and A*X and X*A
%   are Hermitian. The computation is based on SVD(A) and any
%   singular values less than a tolerance are treated as zero.
%   The default tolerance is MAX(SIZE(A)) * NORM(A) * EPS(class(A)).
%
%   PINV(A,TOL) uses the tolerance TOL instead of the default.
%
%   Class support for input A: 
%      float: double, single
%
%   See also RANK.

%   Copyright 1984-2004 The MathWorks, Inc. 
%   $Revision: 5.12.4.2 $  $Date: 2004/12/06 16:35:27 $

if isempty(A)     % quick return
  X = zeros(size(A'),class(A)); 
  A2 = A;
  s = [];
  return  
end

[m,n] = size(A);

if n > m
   [X,A2,s] = pinv2(A',varargin{:});
   X = X';
   A2 = A2';
else
   [U,S,V] = svd(A,0);
   if m > 1, s = diag(S);
   elseif m == 1, s = S(1);
   else s = 0;
   end
   if nargin == 2
      tol = varargin{1};
   else
      tol = max(m,n) * eps(max(s));
   end
   r = sum(s > tol);
   if (r == 0)
      X = zeros(size(A'),class(A));
      A2 = X;
   else
      S2 = diag(ones(r,1)./s(1:r));
      X = V(:,1:r)*S2*U(:,1:r)';
      A2 = U(:,1:r)*S2*V(:,1:r)';
   end
end
