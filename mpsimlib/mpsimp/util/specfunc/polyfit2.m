function [c, S, mu] = polyfit2 (x, y, z, n_x, n_y, method, varargin)
    if (nargin < 5) || isempty(n_y),  n_y = n_x;  end
    if (nargin < 6),  method = [];  end
        
    S = [];
    if (nargout == 3)
        mu = [mean(x), std(x); mean(y), std(y)];
        x = (x - mu(1,1)) ./ mu(1,2);
        y = (y - mu(2,1)) ./ mu(2,2);
    end        
        
    c_approx = zeros(n_x+1, n_y+1);
    A = polydesign2a (x, y, c_approx);
    c = fit2 (A, z, method, varargin{:});
    c = reshape(c, n_x+1, n_y+1);
end

%!shared
%! N = 10 + ceil(10*rand);
%! x = rand(N,1);
%! y = rand(N,1);

%!test
%! z = rand(N,1);
%! c = polyfit2 (x, y, z, 0, 0);
%! myassert (size(c), [1 1]);
%! myassert (c, mean(z), -10*eps);

%!test
%! c_10 = rand;
%! z = zeros(N,1) + c_10 .* x;
%! c_answer = polyfit2 (x, y, z, 1, 0);
%! c = [0; c_10];
%! %c_answer - c  % DEBUG
%! myassert (size(c), [2 1]);
%! myassert (c_answer, c, -10*eps);

%!test
%! c_01 = rand;
%! z = zeros(N,1) + c_01 .* y;
%! c_answer = polyfit2 (x, y, z, 0, 1);
%! c = [0 c_01];
%! %c_answer - c  % DEBUG
%! myassert (size(c), [1 2]);
%! myassert (c_answer, c, -10*eps);

%!test
%! c_00 = rand;
%! c_10 = rand;
%! c_01 = rand;
%! c_11 = rand;
%! z = c_00 + c_10 .* x + c_01 .* y + c_11 .* x .* y;
%! c_answer = polyfit2 (x, y, z, 1, 1);
%! c = [c_00 c_01; c_10 c_11];
%! %c_answer - c  % DEBUG
%! myassert (size(c), [2 2]);
%! myassert (c_answer, c, -1000*eps);

%!test
%! % If n_y is not given, it is assumed n_y = n_x.
%! z = rand(N,1);
%! c_answer1 = polyfit2 (x, y, z, 1);
%! c_answer2 = polyfit2 (x, y, z, 1, 1);
%! %c_answer1 - c_answer2  % DEBUG
%! myassert (c_answer1, c_answer2);

%!test
%! mu = [mean(x), std(x); mean(y), std(y)];
%! x2 = (x - mu(1,1)) ./ mu(1,2);
%! y2 = (y - mu(2,1)) ./ mu(2,2);
%! 
%! c_00 = rand;
%! c_10 = rand;
%! c_01 = rand;
%! c_11 = rand;
%! z = c_00 + c_10 .* x2 + c_01 .* y2 + c_11 .* x2 .* y2;
%! 
%! c = [c_00 c_01; c_10 c_11];
%! c_answer1 = polyfit2 (x2, y2, z, 1, 1);
%! [c_answer2, temp, mu_answer] = polyfit2 (x, y, z, 1, 1);
%! myassert (size(c), [2 2]);
%! myassert (mu_answer, mu);
%! myassert (c_answer1, c, -1000*eps);
%! myassert (c_answer2, c, -1000*eps);

