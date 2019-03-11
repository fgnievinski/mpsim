function varargout = diff_func_fwd (f, x, h)
    if (nargin < 3) || isempty(h),  h = nthroot(eps, 3);  end
    %whos x h  % DEBUG

    fc = f(x);
    ff = f(x+h);

    j = (ff - fc) ./ h;
    J = spdiag(j);
    
    switch nargout
    case 1,  varargout = {J};
    case 2,  varargout = {fc, J};
    end
end

%!test
%! tol = sqrt(eps());
%! f = @sin;
%! fprime = @cos;
%! x = rand(2,1);
%! fc = f(x);
%! J = spdiag(fprime(x));
%! [fc2, J2] = diff_func_fwd (f, x, tol);
%! J3 = diff_func_fwd (f, x, tol);
%! %[fc fc2 fc2-fc]  % DEBUG
%! %[J J2 J2-J]  % DEBUG
%! %[J2 J3 J3-J2]  % DEBUG
%! myassert(fc2, fc2, -sqrt(tol))
%! myassert(J, J2, -sqrt(tol))
%! myassert(J3, J2)  % must match exactly
