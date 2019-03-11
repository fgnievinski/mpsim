% This is a simplification of Valery Zavorotny's refl_mlm.m
function [rbh,rbv] = refl_mlm2(thickness, eps, fr, angle)
    lambda = get_standard_constant('c')/fr;
    kw=2*pi/lambda;
    si=sind(angle);
    nl = numel(thickness) + 2;
    for m=1:nl-1
        sq1h = sqrt(eps(m)  -eps(nl).*si.^2);
        sq2h = sqrt(eps(m+1)-eps(nl).*si.^2);
        sq1v = eps(m+1).*sq1h;
        sq2v = eps(m)  .*sq2h;
        rth = (sq2h - sq1h)./(sq2h + sq1h);
        rtv = (sq2v - sq1v)./(sq2v + sq1v);
        if (m == 1)
          rbh = rth;
          rbv = rtv;
          continue;
        end
        dz = thickness(m-1);
        psi = 2*kw.*dz.*sq1h;
        q = exp(1i*psi);
        rbh = (rth + rbh.*q)./(1 + rth.*rbh.*q);
        rbv = (rtv + rbv.*q)./(1 + rtv.*rbv.*q);
    end
end
