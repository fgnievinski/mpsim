function y = besselj_fast (n, x)
    %y = besselj(n, x);  return;  disp('hw!');  % DEBUG
    if (n~=0) || ~isreal(x)
        y = besselj(n, x);
        return;
    end
    y = besselj0_fast(x);
end

%!test
%! besselj_fast(0,rand);
%! besselj_fast(1,rand);
%! % we check for correctness in besselj0_fast.m:
%! test('besselj0_fast', [], ...
%!     [fileparts(which('do_addpath')) filesep 'util\private']);

