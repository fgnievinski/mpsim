function [slope, aspect, dir_nrml] = horizgrad2slopeaspect (dz_dx, dz_dy)
    siz = size(dz_dx);  myassert(size(dz_dy), siz);  n = prod(siz);
    dz_dx = reshape(dz_dx, [n,1]);
    dz_dy = reshape(dz_dy, [n,1]);
    dir_nrml_cart = horizgrad2sfcnrml (dz_dx, dz_dy);
    [slope, aspect, dir_nrml] = sfcnrml2slopeaspect (dir_nrml_cart);
    slope  = reshape(slope, siz);
    aspect = reshape(aspect, siz);
end

%!shared
%! rand('seed',0)  % DEBUG

%!test
%! % almost horizontal surface:
%! [slope, aspect] = horizgrad2slopeaspect (0, -1/100);
%! myassert(abs(slope-0) < abs(slope - 90))  % should be closer to zero than 90.
%! %error('stop!')  % DEBUG

%!test
%! % trivial cases calculated by hand:
%! slope = 45;
%! aspect = 0;
%! dz_dx = 0;
%! dz_dy = -1;
%! 
%! [slope2, aspect2] = horizgrad2slopeaspect (dz_dx, dz_dy);
%! [dz_dx2, dz_dy2] = slopeaspect2horizgrad (slope, aspect);
%! 
%!   %[slope,  slope2,  slope2  - slope]
%!   %[aspect, aspect2, aspect2 - aspect]
%!   %[dz_dx,  dz_dx2,  dz_dx2  - dz_dx]
%!   %[dz_dy,  dz_dy2,  dz_dy2  - dz_dy]
%! myassert(slope2,  slope, -sqrt(eps()))
%! myassert(aspect2, aspect, -sqrt(eps()))
%! myassert(dz_dx2,  dz_dx, -sqrt(eps()))
%! myassert(dz_dy2,  dz_dy, -sqrt(eps()))
%! %error('stop!')  % DEBUG

%!test
%! % for an y-aligned direction, we must have dz/dx = 0.
%! slope = 1;
%! aspect = 0;
%! 
%! [dz_dx2, dz_dy2] = slopeaspect2horizgrad (slope, aspect);
%! 
%! myassert(dz_dx2, 0, -sqrt(eps()))
%! %error('stop!')  % DEBUG  % DEBUG
%! % horizgrad2slopeaspect()

%!test
%! % for dz/dx=dz/dy = 0, we must have slope = 0.
%! dz_dx = 0;
%! dz_dy = 0;
%! 
%! [slope, aspect] = horizgrad2slopeaspect (dz_dx, dz_dy);
%! 
%! myassert(slope, 0, -sqrt(eps()))
%! myassert(aspect, 0, -sqrt(eps()))
%! %error('stop!')  % DEBUG

%!test
%! % for any value of aspect, dz/dx=dz/dy = 0 if slope = 0.
%! slope = 0;
%! aspect = randint(0,360);
%! 
%! [dz_dx2, dz_dy2] = slopeaspect2horizgrad (slope, aspect);
%! 
%! myassert(dz_dx2, 0, -sqrt(eps()))
%! myassert(dz_dy2, 0, -sqrt(eps()))
%! %error('stop!')  % DEBUG
%! % horizgrad2slopeaspect()

%!test
%! % consitency in forward and inverse calculations:
%! dz_dx = randint(-10,+10);
%! dz_dy = randint(-10,+10);
%! 
%! [slope2, aspect2] = horizgrad2slopeaspect (dz_dx, dz_dy);
%! [dz_dx3, dz_dy3] = slopeaspect2horizgrad (slope2, aspect2);
%! 
%!   %[dz_dx, dz_dx3, dz_dx3 - dz_dx]
%!   %[dz_dy, dz_dy3, dz_dy3 - dz_dy]
%! myassert(dz_dx3, dz_dx, -sqrt(eps()))
%! myassert(dz_dy3, dz_dy, -sqrt(eps()))
%! %error('stop!')  % DEBUG

%!test
%! % consitency in forward and inverse calculations:
%! slope = randint(0,90);
%! aspect = randint(0,360);
%! 
%! [dz_dx2, dz_dy2] = slopeaspect2horizgrad (slope, aspect);
%! [slope3, aspect3] = horizgrad2slopeaspect (dz_dx2, dz_dy2);
%! 
%!   %[slope,  slope3,  slope3  - slope]
%!   %[aspect, aspect3, aspect3 - aspect]
%! myassert(slope3,  slope,  -sqrt(eps()))
%! myassert(aspect3, aspect, -sqrt(eps()))
%! %error('stop!')  % DEBUG

%!#test
%! % non-vector input:
%! test('mygradientm')
