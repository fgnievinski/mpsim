% diff_func2 supports f,x as matrix, whereas
% diff_func support f,x only as a vector.
function [answer, mf, nf] = diff_func2 (f, x, h, sizef)
    %whos x h  % DEBUG
    if (nargin < 3),  h = [];  end
    if (nargin < 4) || isempty(sizef),  sizef = size(f(x));  end
    mf = sizef(1);
    nf = sizef(2);
    [mx, nx] = size(x);

    myassert (isa(f, 'function_handle'));
    if isvector(x)
        x = x(:).';  % make x a row vector
        [mx, nx] = size(x); %#ok<ASGLU>
    else
        myassert (mx == mf);
        % now we'll assume that each row in f_x is independent of 
        % the other rows in f_x, and depends only on the corresponding
        % row of x (see test below, where x is a matrix).
    end

    answer = zeros(mf, nf * nx);
    
    k = 1;
    for j=1:nx
        %[x(:,1:j-1), NaN, x(:,j+1:end)]', x  % DEBUG
        temp_f = @(z) f( [x(:,1:j-1), z, x(:,j+1:end)] );
        %x(:,j), temp_f (x(:,j))  % DEBUG
        if isempty(h) || isscalar(h),  temp_h = h;  else temp_h = h(j);  end
        answer(:,k:k+nf-1) = diff_func (temp_f, x(:,j), temp_h);
        k=k+nf;
    end
end

%!test
%! f = @(x) pi + x(1).^2 + x(2).^3;
%! fprime = @(x) [2*x(1), 3*x(2).^2];
%! x = rand(2,1);
%! a = fprime (x);
%! a2 = diff_func2 (f, x);
%! %fprintf('%g\n', abs((a2-a)./a));
%! myassert (abs((a2-a)./a) < 1e-5);
%! %disp('hw!')

%!test
%! f = @(x) x(1) + exp(x(2)) + exp(x(3));
%! fprime = @(x) [1, exp(x(2)), exp(x(3))];
%! for i=1:10
%!     x = rand(3,1);
%!     a = fprime(x);
%!     a2 = diff_func2 (f, x);
%!     %fprintf('%g\n', abs((a2-a)./a));
%!     myassert (abs((a2-a)./a) < 1e-5);
%! end

%!test
%! f = @(x) sin(x(1)) + cos(x(2));
%! fprime = @(x) [cos(x(1)), -sin(x(2))];
%! for i=1:10
%!     x = rand(2,1)*2*pi;
%!     a = fprime(x);
%!     a2 = diff_func2 (f, x);
%!     %fprintf('%g\n', abs((a2-a)./a));
%!     myassert (abs((a2-a)./a) < 1e-5);
%! end

%!test
%! % f_x returns a vector.
%! f = @(x) ones(10,1)*x(1) + ones(10,1)*x(2);
%! fprime = @(x) [ones(10,1), ones(10,1)];
%! x = rand(2,1);
%! a = fprime(x);
%! a2 = diff_func2 (f, x);
%! %fprintf('%g\n', abs((a2-a)./a));
%! myassert (abs((a2-a)./a) < 1e-5);

%!test
%! % x is a matrix.
%! n = 10;
%! f = @(x) x(:,1) + 2*x(:,2);
%! fprime = @(x) [ones(n,1), 2*ones(n,1)];
%! x = rand(n,2);
%! a = fprime(x);
%! a2 = diff_func2 (f, x);
%! %fprintf('%g\n', abs((a2-a)./a));
%! myassert (abs((a2-a)./a) < 1e-5);

%!test
%! m = ceil(10*rand);
%! n = ceil(10*rand);
%! f = @(x) zeros(m, n);
%! [answer, m2, n2] = diff_func2 (f, 1);
%! myassert(m2, m)
%! myassert(n2, n)

%!test
%! % step as a vector or matrix, not a scalar:
%! f = @(x) pi + x(1).^2 + x(2).^3;
%! fprime = @(x) [2*x(1), 3*x(2).^2];
%! x = rand(2,1);
%! h = repmat(nthroot(eps,3), size(x));
%! a = fprime (x);
%! a2 = diff_func2 (f, x, h);
%! %fprintf('%g\n', abs((a2-a)./a));
%! myassert (abs((a2-a)./a) < 1e-5);
