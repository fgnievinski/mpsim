function ang = angle_range_positive (ang, tol)
    if (nargin < 2) || isempty(tol),  tol = 0;  end  
    if isempty(ang) ...
    || all( (0-tol) <= ang(:) & ang(:) < (360+tol) )
        return;
    end
    idx = isfinite(ang);
    ang(idx) = angle_range_positive_aux (ang(idx), tol);
end

function ang = angle_range_positive_aux (ang, tol)
    if (tol == 0)
        ang = angle(exp(1i*ang*pi/180))*180/pi;  % avoids iterations.
        ang = angle_range_positive_toosmall (ang, tol);
    else
        ang = angle_range_positive_toolarge (ang, tol);
        ang = angle_range_positive_toosmall (ang, tol);
    end
end

function ang = angle_range_positive_toolarge (ang, tol)
    idx = (ang >= (360+tol));
    if ~any(idx),  return;  end
    ang(idx) = mod(ang(idx), 360);
    ang = angle_range_positive_toolarge (ang, tol);
end

function ang = angle_range_positive_toosmall (ang, tol)
    idx = (ang < (0-tol));
    if ~any(idx),  return;  end
    ang(idx) = 360 + ang(idx);
    ang = angle_range_positive_toosmall (ang, tol);
end

%!test
%! temp = [
%!     0       0
%!     180     180
%!     -180    +180
%!     -150    +210
%!     -360    0
%!     +370    +10
%!     -370    +350
%!     +730    +10
%!     -730    +350
%! ];
%! temp(:,3) = angle_range_positive (temp(:,1));
%! %temp  % DEBUG
%! myassert(temp(:,3), temp(:,2), -sqrt(eps()))

%!test
%! n = 10;
%! angle1 = randint(-1000, +1000, n, 1);
%! angle2 = angle_range_positive(angle1, 0);
%! angle3 = angle_range_positive(angle1, eps());  % (requires iteration)
%! angle4 = angle_range_positive(angle2, eps());  % doesn't require iteration
%! %[angle1, angle2, angle3, angle4, angle4-angle3]  % DEBUG
%! myassert(angle4, angle3, -sqrt(eps()))

