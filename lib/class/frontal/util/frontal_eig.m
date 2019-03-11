function varargout = frontal_eig (A, varargin)
    [varargout{1:nargout}] = frontal_func(@eig, A, varargin{:});
end

%!shared
%! c = ceil(10*rand);
%! %A = randsym(c);  % WRONG!  make sure eigenvalues are distinct.
%! A = gallery('minij',c);
%! tol = sqrt(eps());

%!test
%! % frontal matrices with only one page 
%! % can be treated as 2d matrices.
%! d = frontal_eig(A);
%! d2 = eig(A);
%!  %[d, d2, d2-d]  % DEBUG
%! %max(abs(d-d2))  % DEBUG
%! 
%! myassert (d, d2, -tol);
%! 
%! [V,D] = frontal_eig(A);
%! [V2,D2] = eig(A);
%!  %[diag(D), diag(D2), diag(D2)-diag(D)]
%! myassert (D, D2, -tol);
%!  %V, V2, V2-V
%! myassert (V, V2, -tol);

%!test
%! % frontal_eig ()
%! o = ceil(10*rand);
%! d = frontal_eigs(repmat(A, [1,1,o]), 1);
%! d2 = repmat(eigs(A, 1), [1,1,o]);
%! %d = squeeze(d);
%! %d2 = squeeze(d2);
%!  %[d, d2, d2-d]  % DEBUG
%! myassert (d, d2, -tol);

