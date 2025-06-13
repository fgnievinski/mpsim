function [F, E] = ellipfe (phi, M, tol)
    if (nargin < 3) || isempty(tol),  tol = sqrt(eps());  end
    %if isscalar(M), M = repmat (M, size(phi));  end
    n = length(phi);

    F = zeros(n,1);
    E = zeros(n,1);
    k = sqrt(M);
    j = 1;  if isscalar(k), j_delta = 0; else j_delta = 1; end
    for i=1:n
        % notice different convention on arguments'
        % units and order:
        [F(i), E(i)] = elit (k(j), phi(i)*180/pi, tol);
        j = j + j_delta;
    end
return;

%!shared
%! %rand('state', 0)

%!test
%! n = ceil(10*rand);
%! M = rand(n,1);
%! phi = repmat(pi/2, n, 1);
%! [F, E] = ellipfe (phi, M);
%! [F2, E2] = ellipke (M);
%! F_err = F - F2;
%! E_err = E - E2;
%! %max(abs(F - F2)), max(abs(E - E2))
%! myassert (F_err, 0, -sqrt(eps));
%! myassert (E_err, 0, -sqrt(eps));

%!test
%! % multiple points, same eccentricity
%! n = ceil(10*rand);
%! M = rand;
%! phi = repmat(pi/2, n, 1);
%! [F, E] = ellipfe (phi, M);
%! myassert (length(F), n)
%! myassert (length(E), n)

%!test
%! % multiple runs with multiple points and a single eccentricity.
%! % (I wanted to show that the repmat at the begining of the 
%! % function above was slowing it down a lot. Changing/rechanging 
%! % the code I couldn't notice a difference. I couldn't find a way to
%! % automatically check that speed improvement in this test case, too.
%! % Don't forget to enable rand('state', 0) above when repeating tests.
%! 
%! n = 10;%ceil(10*rand);
%! M = rand;
%! phi = repmat(pi/2, n, 1);
%! for i=1:100
%!     [F, E] = ellipfe (phi, M);
%! end
%! myassert (length(F), n)
%! myassert (length(E), n)

function melit
%This program is a direct conversion of the corresponding Fortran program in
%S. Zhang & J. Jin "Computation of Special Functions" (Wiley, 1996).
%online: http://iris-lee3.ece.uiuc.edu/~jjin/routines/routines.html
%
%Converted by f2matlab open source project:
%online: https://sourceforge.net/projects/f2matlab/
% written by Ben Barrowes (barrowes@alum.mit.edu)
%


%       ==========================================================
%       Purpose: This program computes complete and incomplete
%                elliptic integrals F(k,phi) and E(k,phi) using
%                subroutine ELIT
%       Input  : HK  --- Modulus k ( 0 ó k ó 1 )
%                Phi --- Argument ( in degrees )
%       Output : FE  --- F(k,phi)
%                EE  --- E(k,phi)
%       Example:
%                k = .5

%                 phi     F(k,phi)       E(k,phi)
%                -----------------------------------
%                   0      .00000000      .00000000
%                  15      .26254249      .26106005
%                  30      .52942863      .51788193
%                  45      .80436610      .76719599
%                  60     1.08955067     1.00755556
%                  75     1.38457455     1.23988858
%                  90     1.68575035     1.46746221
%       ==========================================================

%
hk=[];phi=[];fe=[];ee=[];
'please enter k and phi (in degs.) ',
%        READ(*,*)HK,PHI
hk=.5;
phi=90;
,
'  phi     f(k,phi)       e(k,phi)',
' -----------------------------------',
%[hk,phi,fe,ee]=elit(hk,phi,fe,ee);
[fe,ee]=elit(hk,phi);
phi,fe,ee,
%format(1x,f6.2,2f13.8);



%function [hk,phi,fe,ee]=elit(hk,phi,fe,ee);
function [fe,ee]=elit(hk,phi,tol)
%                integrals F(k,phi) and E(k,phi)
%       Input  : HK  --- Modulus k ( 0 ó k ó 1 )
%                Phi --- Argument ( in degrees )
%       Output : FE  --- F(k,phi)
%                EE  --- E(k,phi)
%       ==================================================



%
%
%
%
%
g=0.0d0;
pi=3.14159265358979d0;
a0=1.0d0;
b0=sqrt(1.0d0-hk.*hk);
d0=(pi./180.0d0).*phi;
r=hk.*hk;
if (hk == 1.0d0&&phi == 90.0d0) ;
%if (hk == 1.0d0&phi == 90.0d0) ;
    fe=1.0d+300;
    ee=1.0d0;
elseif (hk == 1.0d0);
    fe=log((1.0d0+sin(d0))./cos(d0));
    ee=sin(d0);
else;
    fac=1.0d0;
    for  n=1:40;
%    while true
        a=(a0+b0)./2.0d0;
        b=sqrt(a0.*b0);
        c=(a0-b0)./2.0d0;
        fac=2.0d0.*fac;
        r=r+fac.*c.*c;
        if (phi ~= 90.0d0) ;
            d=d0+atan((b0./a0).*tan(d0));
            g=g+c.*sin(d);
            d0=d+pi.*fix(d./pi+.5d0);
        end;
        a0=a;
        b0=b;
%        if (c < 1.0d-7) break; end;
%        if (c < eps) break; end;
        if (c < tol) break; end;
    end;
    ck=pi./(2.0d0.*a);
    ce=pi.*(2.0d0-r)./(4.0d0.*a);
    if (phi == 90.0d0) ;
        fe=ck;
        ee=ce;
    else;
        fe=d./(fac.*a);
        ee=fe.*ce./ck+g;
    end;
end;
return;

