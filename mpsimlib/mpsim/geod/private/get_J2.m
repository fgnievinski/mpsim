function J2 = get_J2 (a, b, omega, GM, get_q0_b, zero_neg_J2)
%GET_J2: Return the ellipsoid J2 constant (related to flattening), given other ellipsoid defining constants.

    if (nargin < 5) || isempty(get_q0_b),  get_q0_b = false;  end
    if (nargin < 6),  zero_neg_J2 = true;  end
    
    if (a==b),  J2 = 0;  return;  end
    if (b==0)
        % see test case get_J2(a, 0, omega, GM) below.
        f = @(delta) get_J2(a, a+delta, omega, GM, [], true);
        [delta0, fval] = fzero(f, -2e4, -1e4);
        myassert(fval, 0, sqrt(eps))
        J2 = delta0;
        return;
    end

    e       = sqrt( (a.^2 - b.^2) ./ a.^2 );
    e_prime = sqrt( (a.^2 - b.^2) ./ b.^2 );
    m = omega.^2 .* a.^2 .* b ./ GM;
    %m = (omega*(omega*b)) * (a*(a/GM));

    n = 1;
    sum = 0;
    term = eps + eps;
    while any(abs(term) > eps(sum))
        term = 4 * (-1)^(n+1) * n / ((2*n+1)*(2*n+3)) * e_prime.^(2*n+1);
        sum = sum + term;
        n = n + 1;
    end
    q0 = (1/2) * sum;
    if get_q0_b
        q0 = (1/2) * ( (1+3./e_prime.^2).*atan(e_prime) - 3./e_prime );
    end
    
    J2  = e.^2/3.*(1 - (2/15).*m.*(e_prime./q0));

    % GRS80, by H. Moritz

    if zero_neg_J2
        J2(J2<0) = 0;
    end
end

%!test
%! % multiple points
%! n = 1 + ceil(10*rand);
%! J2 = get_J2 (1, repmat(0.5, n, 1), 0, 1);
%! myassert(size(J2), [n, 1])

%!test
%! % J2 = 0 for a = b, by definition.
%! % (formulas above break down for a = b).
%! myassert(get_J2(1, 1, [], []), 0)

%!shared
%! % GRS80 defining and derived constants:
%! a = 6378137;
%! f = 1/298.257222101;
%! b = a*(1-f);
%! % get b from f and a:
%! %b - 6356752.6141  % DEBUG
%! omega = 7292115e-11;
%! GM = 3986005e8;
%! J2 = 108263e-8;
%! tol = 1e-8 / 2;  % half least significant digit in J2.

%!test
%! % check against reported values:
%! J2b = get_J2(a, b, omega, GM);
%! 
%! %[J2, J2b, J2b-J2]
%! myassert(J2b, J2, -tol)

%!test
%! % compare different implementations for q0:
%! % (J2 should vary smoothly as b->a).
%! delta = [-10:+1:-2, -1:+0.1:-0.1]';
%! b = a + delta;
%! myassert (all(a > b));
%! 
%! J2  = get_J2 (a, b, omega, GM, [], false);
%! J2b = get_J2 (a, b, omega, GM, true, false);
%! 
%! %figure
%! %subplot(1,2,1), plot(delta, J2,  '.-')
%! %subplot(1,2,2), plot(delta, J2b, '.-')
%! temp = corrcoef(delta, J2);   c  = temp(2,1);
%! temp = corrcoef(delta, J2b);  cb = temp(2,1);
%! 
%! %[J2, J2b, J2b-J2]
%! %[c, cb], [c, cb] - (-1)  % DEBUG
%! myassert(c, -1, -sqrt(eps));

%!test
%! % Interesting, J2(b==a)<>0, J2(a<>b)==0.
%! % I.e., for a sphere (b==a), J2 is different than zero.
%! % I think this behavior is NOT physical, just a 
%! % numerical artifact that should be suppressed.
%! 
%! delta = linspace(b-a, 0, 10)';  delta(end) = [];
%! b = a + delta;
%! myassert (all(a > b));
%! 
%! J2  = get_J2 (a, b, omega, GM, [], false);
%! J2b = get_J2 (a, b, omega, GM);
%! 
%! %[delta, J2, J2-J2(1)]
%! %figure
%! %plot(delta, J2,  '.-')
%! %[J2, J2b]
%! myassert(~any(J2b < 0))
%! 
%! delta0 = get_J2(a, 0, omega, GM);
%! J20 = get_J2(a, a+delta0, omega, GM);
%! myassert(J20, 0, -sqrt(eps));
%! % is it affected by the lack of precision? NO!
%! J20 = get_J2(a, a+single(delta0), omega, GM);
%! myassert(isa(J20, 'single'));
%! myassert(J20, 0, -sqrt(eps(single(1))));
%! % b=a+delta0 yields J2=0.

%!test
%! % Trying to analyze J2 at the limit b->a.
%! delta = [-10:+1:-2, -1:+0.1:-0.2, -0.1:+0.01:-0.02]';
%! b = a + delta;
%! 
%! J2 = get_J2 (a, b, omega, GM, [], false);
%! J20 = interp1(delta, J2, 0, 'linear', 'extrap');
%! % J20 = J2(a==b).
%! temp = corrcoef(delta, J2);   c = temp(2,1);
%! 
%! %figure, plot(delta, J2, '.-k');
%! %J20, c
%! myassert(c, -1, -sqrt(eps))

