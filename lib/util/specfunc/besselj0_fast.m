% I've vectorized mjy01b.m.
% 
% MATLAB routines for computation of Special Functions
% http://ceta.mit.edu/ceta/comp_spec_func/
% This program is a direct conversion of the corresponding Fortran program in
% S. Zhang & J. Jin "Computation of Special Functions" (Wiley, 1996).
% online: http://iris-lee3.ece.uiuc.edu/~jjin/routines/routines.html
% 
% Converted by f2matlab open source project:
% online: https://sourceforge.net/projects/f2matlab/
%  written by Ben Barrowes (barrowes@alum.mit.edu)
% 
%  mjy01a.m (JY01A) Evaluate the zeroth- and first-order Bessel functions of the first and second kinds with real arguments using series and asymptotic expansions.
% 
%  mjy01b.m (JY01B) Evaluate the zeroth- and first-order Bessel functions of the first and second kinds with real arguments using polynomial approximations. 
function y = besselj0_fast (x)
    myassert(isreal(x));
    y = zeros(size(x));
    i = (x==0);      y(i) = doit_eq0 (x(i));
    i = (0<x&x<=4);  y(i) = doit_le4 (x(i));
    i = (x>4);       y(i) = doit_gt4 (x(i));
end

function bj0 = doit_eq0 (x)
    bj0=ones(size(x));
end
function bj0 = doit_le4 (x)
    t=x./4.0;
    t2=t.*t;
    bj0=((((((-.5014415e-3.*t2+.76771853e-2).*t2-.0709253492).*t2+.4443584263).*t2 -1.7777560599).*t2+3.9999973021).*t2-3.9999998721).*t2+1.0;
end
function bj0 = doit_gt4 (x)
    t=4.0./x;
    t2=t.*t;
    a0=sqrt(2.0./(pi.*x));
    p0=((((-.9285e-5.*t2+.43506e-4).*t2-.122226e-3).*t2+.434725e-3).*t2-.4394275e-2).*t2+.999999997;
    q0=t.*(((((.8099e-5.*t2-.35614e-4).*t2+.85844e-4).*t2-.218024e-3).*t2+.1144106e-2).*t2-.031249995);
    ta0=x-.25.*pi;
    bj0=a0.*(p0.*cos(ta0)-q0.*sin(ta0));
end

%!test
%! x = (0:0.1:5)';  % sample all cases.
%! tol = sqrt(eps);
%! out = besselj (0, x);
%! out2 = besselj0_fast (x);
%! %[out, out2, out2-out]  % DEBUG
%! myassert(out2, out, -tol)

