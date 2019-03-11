function [Q, P2, X2] = unwrapr (P, n, tol, dim, flt_type)
  if (nargin < 2) || isempty(n),    n = 3;  end
  if (nargin < 3) || isempty(tol),  tol = pi;  end
  if (nargin < 4) || isempty(dim),  dim = finddim(P);  end
  if (nargin < 5) || isempty(flt_type),  flt_type = 'median';  end
  X = exp(1i*P);
  switch lower(flt_type)
  case 'median',  X2 = medfilt1c (X, n, dim);
  case 'mean',  X2 = meanfilt1 (X, n, dim);
  case 'poly', X2 = polyfilt1 (X, n, dim);
  end
  P2 = angle (X2);
  Q2 = unwrap (P2, tol, dim);
  O2 = Q2 - P2;
  O = O2;
  Q = P + O;
end

%%
function y = polyfilt1 (x, n, dim)
  assert(dim==1)
  deg = 2;
  f = @(t, x, tk) polyval(nanpolyfit(t-tk, x, deg), 0); 
  y = smoothit((1:numel(x))',x,n,[],f,true,true);
end

%%
function y = medfilt1c (x, n, dim)
  blksz = size(x, dim);
  y = complex(...
    medfilt1(real(x), n, blksz, dim), ...
    medfilt1(imag(x), n, blksz, dim)  ...
  );
end

%%
%!test
%! %%
%! dt = 0.005;
%! Dt = 1;
%! t = (0:dt:Dt)';
%! f = 2*pi*1/(Dt);
%! A = 5;
%! p = [Dt*10, 0];
%! Pa = A.*sin(f.*t) + polyval(p,t);
%!  %fpk Pa
%! 
%! %%
%! Pb = angle(exp(1i*Pa));
%!  %fpk Pb
%! Qb = unwrap(Pb);
%!  fpk Qb
%! [Qbr, Pbr, Xbr] = unwrapr(Pb,10);
%!  fpk t imag(Xbr)
%!  fpk Pbr
%!  fpk Qbr
%!  
%! %%
%! rng(0);
%! s = A/2;
%! Pc = Pb + s.*randn(size(t));
%!  fpk Pc
%! Qc = unwrap(Pc);
%!  fpk Qc
%!  
%! %%
%! [Qcr, Pcr, Xcr] = unwrapr(Pc,5);
%! Xc = exp(1i*Pc);
%!  figure
%!  hold on
%!  plot(t, imag(Xc ), '.-r')
%!  plot(t, imag(Xcr), '.-b')
%! 
%!  fpk Pcr
%!  fpk Qcr
