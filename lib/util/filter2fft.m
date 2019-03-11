function [out, Xfft] = filter2fft (h, X, shape, Xfft, get_pow2)
    if (nargin < 3) || isempty(shape),  shape = 'same';  end
    %if (nargin < 3) || isempty(shape),  shape = 'full';  end  % WRONG!
    if (nargin < 4),  Xfft = [];  end
    if (nargin < 5),  get_pow2 = [];  end
    h = rot90(h, 2);  % consistency with filter2.
    [out, Xfft] = conv2fft (h, X, shape, Xfft, get_pow2);
end

%!test
%! %rand('seed',0)  % DEBUG
%! sizes = ceil(10*rand(1,4));
%! h = rand(sizes(1:2));
%! %h = 1;  % DEBUG
%! X = rand(sizes(3:4));
%! for shape={'same','full','valid'},  shape = shape{1};
%! for get_pow2=[true, false]
%!   %shape, get_pow2  % DEBUG
%!   outa = filter2 (h, X, shape);
%!   [outb, Xfft] = filter2fft (h, X, shape, [], get_pow2);
%!   outc = filter2fft (h, X, shape, Xfft, get_pow2);
%!   %outa, outb
%!   %outc - outb
%!   %outb - outa
%!   %max(abs(outb(:) - outa(:)))  % DEBUG
%!   %max(abs(outc(:) - outb(:)))  % DEBUG
%!   myassert(outb, outa, -100*eps())
%!   myassert(outc, outb)
%! end
%! end

