function [X, d, A2] = sqrtmsym (A, varargin)
    [V, d] = eigsym (A, varargin{:});
    X = V*diag(sqrt(d))*V';
    if (nargout < 3),  return;  end
    A2 = V*diag(d)*V';
end

%!test
%! A = randsym(4);
%! As = sqrtm(A);
%! for force_sparse=[true,false]
%!   [As2,ignore,A2] = sqrtmsym (A, 4, force_sparse);
%!   tol = sqrt(eps());
%!     %max(max(abs(As2-As)))  % DEBUG
%!     %max(max(abs(A2-A)))  % DEBUG
%!   myassert(As, As2, -tol)
%!   myassert(A, A2, -tol)
%! end

