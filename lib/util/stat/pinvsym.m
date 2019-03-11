function [X, d, A2] = pinvsym (A, varargin)
    [V, d] = eigsym (A, varargin{:});
    X = V*diag(1./d)*V';
    if (nargout < 3),  return;  end
    A2 = V*diag(d)*V';
end

%!test
%! A = randsym(4);
%! Ai = inv(A);
%! for force_sparse=[true,false]
%!   [Ai2,ignore,A2] = pinvsym (A, 4, force_sparse);
%!   tol = sqrt(eps());
%!     %max(max(abs(Ai2-Ai)))  % DEBUG
%!     %max(max(abs(A2-A)))  % DEBUG
%!   myassert(Ai, Ai2, -tol)
%!   myassert(A, A2, -tol)
%! end

