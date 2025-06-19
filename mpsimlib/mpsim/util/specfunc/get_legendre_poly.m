function P_n = get_legendre_poly (nn, t)
    myassert( ~(nn < 0) );
    nt = length(t);
    
    P_0 = ones(nt, 1);
    if (nn == 0), P_n = P_0;  return;  end
    P_1 = t;
    if (nn == 1), P_n = P_1;  return;  end

    P_n_minus1 = P_1;  % previous one
    P_n_minus2 = P_0;  % the one before the previous one
    for n=2:1:nn
        P_n =  ((2*n - 1) / n) * t .* P_n_minus1 ...
              -((  n - 1) / n) * P_n_minus2;
        % The recurrence formula above is given in Torge (2000),
        % Geodesy, 3rd ed., eq. (3.80b), p. 67. It's also given in
        %  Eric W. Weisstein. "Legendre Polynomial." From MathWorld
        % --A Wolfram Web Resource. 
        % <http://mathworld.wolfram.com/LegendrePolynomial.html>
        
        P_n_minus2 = P_n_minus1;
        P_n_minus1 = P_n;
    end
end

%!test
%! x = rand;
%! % The first few Legendre polynomials are
%! P_0 = 1;
%! P_1 = x;
%! P_2 = (1/2) * (3*x^2 - 1);
%! P_3 = (1/2) * (5*x^3 - 3*x);
%! P_4 = (1/8) * (35*x^4 - 30*x^2 + 3);
%! P_5 = (1/8) * (63*x^5 - 70*x^3 + 15*x);
%! P_6 = (1/16) * (231*x^6 - 315*x^4 + 105*x^2 - 5);
%! % Eric W. Weisstein. "Legendre Polynomial." From MathWorld--A Wolfram Web 
%! % Resource. <http://mathworld.wolfram.com/LegendrePolynomial.html>
%! myassert ( abs(get_legendre_poly (0, x) - P_0) < 100*eps );
%! myassert ( abs(get_legendre_poly (1, x) - P_1) < 100*eps );
%! myassert ( abs(get_legendre_poly (2, x) - P_2) < 100*eps );
%! myassert ( abs(get_legendre_poly (3, x) - P_3) < 100*eps );
%! myassert ( abs(get_legendre_poly (4, x) - P_4) < 100*eps );
%! myassert ( abs(get_legendre_poly (5, x) - P_5) < 100*eps );
%! myassert ( abs(get_legendre_poly (6, x) - P_6) < 100*eps );

%!test
%! % multiple points:
%! x = rand(10, 1);
%! P_6 = (1/16) * (231*x.^6 - 315*x.^4 + 105*x.^2 - 5);
%! %abs(get_legendre_poly (6, x) - P_6)
%! myassert(all( abs(get_legendre_poly (6, x) - P_6) < 100*eps ));

