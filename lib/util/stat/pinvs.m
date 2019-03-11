function [X,s,A2] = pinvs (A,varargin)

if isempty(A)     % quick return
  X = zeros(size(A'),class(A)); 
  A2 = A;
  s = [];
  return  
end

[m,n] = size(A);

if n > m
   [X,A2,s] = pinvs(A',varargin{:});
   X = X';
   A2 = A2';
else
   [U,S,V] = svds(A, varargin{:});
   s = diag(S);
   r = numel(s);
   if (r == 0)
      X = zeros(size(A'),class(A));
      A2 = X;
   else
      S2 = diag(1./s);
      X = V*S2*U';
      A2 = U*S2*V';
   end
end
