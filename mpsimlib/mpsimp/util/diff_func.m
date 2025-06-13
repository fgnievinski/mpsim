function [d,h] = diff_func (f, x, h, check_size)
    if (nargin < 3) || isempty(h),  h = nthroot(eps, 3);  end
    if (nargin < 4) || isempty(check_size),  check_size = false;  end
    %whos x h  % DEBUG
    %if h ~= nthroot(eps, 4), error('hw!'); end  % DEBUG

    fl = f(x-h);
    fr = f(x+h);

    if ~isscalar(x) && check_size
        myassert (size(x,1) == size(fl,1));
        myassert (size(x,1) == size(fr,1));
        % Now we assume that each row in f's output 
        % depends only on the same row in the input x.
    end

    d = (fr - fl) / (2*h);

    % A better implementation would provide an estimate for
    % the error in the numerical derivative, and also
    % choose the best value for h.
    % See, e.g., Burden & Faires, Numerical Analysis.
end

%!test
%! f = @exp;
%! fprime = @exp;
%! x = 100;
%! a = fprime(x);
%! a2 = diff_func (f, x);
%! %fprintf('%g\n', abs((a2-a)/a));
%! myassert (abs((a2-a)/a) < 1e-9);

%!test
%! f = @exp;
%! fprime = @exp;
%! x = rand(10,1);
%! a = fprime(x);
%! a2 = diff_func (f, x);
%! %fprintf('%g\n', a2-a);
%! myassert (a2, a, -1e-10);

%!test
%! f = @sin;
%! fprime = @cos;
%! x = rand(10,1)*2*pi;
%! a = fprime(x);
%! a2 = diff_func (f, x);
%! %fprintf('%g\n', a2-a);
%! myassert (a2, a, -1e-10);

%!test
%! f = @cos;
%! fprime = @(x) -sin(x);
%! x = rand(10,1)*2*pi;
%! a = fprime(x);
%! a2 = diff_func (f, x);
%! %fprintf('%g\n', a2-a);
%! myassert (a2, a, -1e-10);

%!test
%! % default step size.
%! f = @cos;
%! x = rand(10,1)*2*pi;
%! [a2, h] = diff_func (f, x);
%! a3 = diff_func (f, x, h);
%! a4 = diff_func (f, x, []);
%! myassert (a3, a2, 0);
%! myassert (a4, a2, 0);

