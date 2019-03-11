function [XYZ_out, R] = myrotate (ang, XYZ_in)
    R_X = get_rot (1, ang(1));
    R_Y = get_rot (2, ang(2));
    R_Z = get_rot (3, ang(3));
    
    %R = R_X * R_Y * R_Z;
    R = R_Z * R_Y * R_X;

    if (nargin < 2),  XYZ_out = [];  return;  end  % user wants R only.
    XYZ_out = transpose(R*transpose(XYZ_in));
end

%!shared
%! n = round(100*rand);
%! lat = 180*rand(n,1) - 90;
%! lon = 360*rand(n,1) - 180;
%! [X, Y, Z] = sph2cart (lat*pi/180, lon*pi/180, 6370e3);
%!     XYZ_in = [X, Y, Z];  clear X Y Z

%!test
%! myassert(myrotate([0,0,0], XYZ_in), XYZ_in);

%!test
%! % rotation around X-axis leaves X-coord intact:
%! XYZ_out = myrotate([rand,0,0], XYZ_in);
%! myassert(XYZ_out(:,1), XYZ_in(:,1), -eps);

%!test
%! % rotation around Y-axis leaves Y-coord intact:
%! XYZ_out = myrotate([0,rand,0], XYZ_in);
%! myassert(XYZ_out(:,2), XYZ_in(:,2), -eps);

%!test
%! % rotation around Z-axis leaves Z-coord intact:
%! XYZ_out = myrotate([0,0,rand], XYZ_in);
%! myassert(XYZ_out(:,3), XYZ_in(:,3), -eps);

%!test
%! % 90 degrees rotation around X-axis, bringing Z-axis
%! % into coincidence with Y-axis.
%! XYZ_in = [0, 0, 1];
%! XYZ_out = [0, 1, 0];
%! XYZ_out2 = myrotate([90,0,0], XYZ_in);
%! myassert(XYZ_out2, XYZ_out, -eps);

%!test
%! % 90 degrees rotation around Y-axis, bringing X-axis
%! % into coincidence with Z-axis.
%! XYZ_in = [1, 0, 0];
%! XYZ_out = [0, 0, 1];
%! XYZ_out2 = myrotate([0,90,0], XYZ_in);
%! myassert(XYZ_out2, XYZ_out, -eps);

%!test
%! % 90 degrees rotation around Z-axis, bringing Y-axis
%! % into coincidence with X-axis.
%! XYZ_in = [0, 1, 0];
%! XYZ_out = [1, 0, 0];
%! XYZ_out2 = myrotate([0,0,90], XYZ_in);
%! myassert(XYZ_out2, XYZ_out, -eps);

