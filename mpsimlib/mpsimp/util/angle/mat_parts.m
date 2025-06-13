function [deg, min, sec, sig] = mat_parts(mat)
    deg = abs(mat(:,1));
    min = abs(mat(:,2));
    sec = abs(mat(:,3));
    if (size(mat,2) > 3)
        sig = mat(:,4);
    else
        sig = sign(mat(:,1));
    end
end

%!test
%! [a, b, c, d] = mat_parts([1 2 3 +1]);
%! myassert(a, 1)
%! myassert(b, 2)
%! myassert(c, 3)
%! myassert(d, +1)

%!test
%! % sign field takes precedence over deg, min, sec values
%! [a, b, c, d] = mat_parts([-1 +2 -3 +1]);
%! myassert(a, 1)
%! myassert(b, 2)
%! myassert(c, 3)
%! myassert(d, +1)

%!test
%! % no sign field:
%! [a, b, c, d] = mat_parts([-1 +2 -3]);
%! myassert(a, 1)
%! myassert(b, 2)
%! myassert(c, 3)
%! myassert(d, -1)

