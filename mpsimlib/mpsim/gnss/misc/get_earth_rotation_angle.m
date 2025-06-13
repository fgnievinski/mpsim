function ERA = get_earth_rotation_angle (epoch, leap_seconds, UT1_minus_UTC)
    if (nargin < 2),  leap_seconds = 0;  end
    if (nargin < 3),  UT1_minus_UTC = 0;  end  % For higher accuracy, use IERS Bulletins.
    epoch = reshape(epoch, length(epoch), 1);

    GPST = epoch;  % input epoch is in GPS time.

    UTC = GPST + leap_seconds;

    UT1 = UTC + UT1_minus_UTC;

    Tu = mydatejd(UT1) - 2451545.0;

    % eq. (14) in chapter 10 of IERS Conventions (2003):
    ERA = 2*pi.* (mod(Tu,1) + 0.7790572732640 + 0.00273781191135448 .* Tu);
    %whos  % DEBUG
end

%!test
%! epoch1 = mydatenum([2007 01 01  0 0 0]);
%! epoch2 = mydatenum([2008 01 01  0 0 0]);
%! epoch3 = mydatenum([2007 01 02  0 0 0]);
%! ang1 = get_earth_rotation_angle (epoch1, 0);
%! ang2 = get_earth_rotation_angle (epoch2, 0);
%! ang3 = get_earth_rotation_angle (epoch3, 0);
%! dang2 = ang2 - ang1;
%! dang3 = ang3 - ang1;
%! 
%! % approximate angles:
%! dang2b = 2*pi;
%! dang3b = 2*pi;
%! 
%! %dang2*180/pi, dang3*180/pi  % DEBUG
%! 
%! tol = 1*pi/180;
%! %mod(dang2b,2*pi), mod(dang2,2*pi), -tol  % DEBUG
%! %mod(dang3b,2*pi), mod(dang3,2*pi), -tol  % DEBUG
%! %mod(dang2b - dang2,2*pi)  % DEBUG
%! %mod(dang3b - dang2,2*pi)  % DEBUG
%! myassert(mod(dang2b - dang2,2*pi), 0, -tol)
%! myassert(mod(dang3b - dang2,2*pi), 0, -tol)

%!test
%! % multiple epochs:
%! n = ceil(10*rand);
%! epoch = rand(n,1);
%! ang = NaN(n,1);
%! for i=1:n
%!     ang(i) = get_earth_rotation_angle (epoch(i), 0);
%! end
%! ang2 = get_earth_rotation_angle (epoch, 0);
%! %ang2, ang  % DEBUG
%! myassert(ang2, ang)

%!test
%! % NaN in input:
%! n = ceil(10*rand);
%! epoch = rand(n,1);
%! ang = NaN(n,1);
%! for i=1:n
%!     ang(i) = get_earth_rotation_angle (epoch(i), 0);
%! end
%! ang2 = get_earth_rotation_angle (epoch, 0);
%! %ang2, ang  % DEBUG
%! myassert(ang2, ang)
