function G = get_meridian_arclen (lat, ell)
%GET_MERIDIAN_ARCLEN: Return the meridian arc length (at zero height), from the equator up to a given latitude.

    % negative latitudes yield negative arc lengths:
    neg_idx = (lat < 0);
    lat = abs(lat);
    
    % handle latitudes in excess of 90 degrees (positive or negative)
    % in such a way that their derivatives are correct:
    exc_idx = (lat > 90);
    lat_exc = lat(exc_idx) - 90;  % latitude value in excess of 90 degrees
    lat(exc_idx) = 90 - lat_exc;  % make 91 degrees 89 degrees
    myassert (~any (lat > 90));

    lat2 = lat*pi/180;
    e = ell.e;  a = ell.a;

    [F, E] = ellipfe (lat2, e^2);
    temp = e^2 * sin(lat2) .* cos(lat2) ./ sqrt(1 - e^2 * sin(lat2).^2);

    G = a * (E - temp);

    if any(exc_idx)
    G_90 = get_meridian_arclen (90, ell);
    G_exc = G_90 - G(exc_idx);  % arc length in excess of that at 90 degrees
    G(exc_idx) = G_90 + G_exc;
    end

    G(neg_idx) = -1 * G(neg_idx);
    
    % For formulas, please see:
    %     [3] Dorrer, E. From Elliptc Arc Length to Gauss-Kr\"uger Coordinates by Analytical Continuation. In: Krumm, F. and Schwarze, V. (Eds.) ``Festschrift for Erik W. Grafarend on the occasion of his 60th birthday.'' 1996. Report Nr. 1999.6, Universit\"t Stuttgart, Schriftenreihe der Institute des Studiengangs Geod\"asie und Geoinformatik, Technical Reports Department of Geodesy and Geoinformatics. ISSN 0933-2839. \url{http://www.uni-stuttgart.de/gi/research/schriftenreihe/quo_vadis/pdf/dorrer.pdf}.\par
    % Section 2 in Dorrer's paper is worth reading (please note that in his original expressions arc length is normalized to a = 1).
    % (if Adobe Reader says there is a font missing in the PDF document above, open it using Ghostgum/GhostScript).
end

%!shared
%! function G = get_meridian_arc_length2 (lat, ell)
%!     n = length(lat);
%!     M = @(lat2) compute_meridian_radius (lat2*180/pi, ell);
%!     lat2 = lat*pi/180;
%!     G = zeros(n,1);
%!     warning ('off', 'MATLAB:quadl:MinStepSize');
%!     for i=1:n
%!         G(i) = quadl(M, 0, lat2(i), sqrt(eps));
%!     end
%!     warning ('on', 'MATLAB:quadl:MinStepSize');
%! end
%! 
%! n = ceil(100*rand);
%! lat = linspace (0, +90, n)';
%! myassert(all( -90 <= lat & lat <= +90 ));
%! ell = get_ellipsoid('grs80');

%!test
%! % A negative latitude should yield a negative meridian arc length.
%! Gp = get_meridian_arclen (+abs(lat), ell);
%! Gn = get_meridian_arclen (-abs(lat), ell);
%! 
%! %lat
%! %[Gp, Gn]
%! myassert (Gp, -Gn)

%!test
%! % When the ellipse degenerates onto a circle, 
%! % calculation of the meridian arc length 
%! % is much simplified.
%! ell.b = ell.a;  ell.e = 0;  ell.f = 0;
%! G1 = ell.a * lat * pi/180;
%! G2 = get_meridian_arclen (lat, ell);
%! 
%! %lat
%! %[G1, G2]
%! %[G1 - G2]
%! myassert (G1, G2, -10*sqrt(eps))

%!test
%! % Here we use a general numerical quadrature routine, quadl(), 
%! % to calculate the meridian arc length from its very definition,
%! % i.e., the integral of meridian radius of curvature, 
%! % from the Equator up to the given latitude.
%! % See, e.g., section 3.4.2, p.51 in Torge (1980) "Geodesy".
%! % 
%! % The general numerical quadrature should be much slower than 
%! % the specialized elliptical integral. We check tha, too.
%! 
%! tic;
%! G1 = get_meridian_arc_length2 (lat, ell);
%! toc1 = toc;
%! 
%! tic; 
%! G2 = get_meridian_arclen (lat, ell);
%! toc2 = toc;
%! 
%! %[G2, G1]
%! %max(abs([G2 - G1]))
%! myassert (G2, G1, -10*sqrt(eps))
%! %toc1, toc2
%! myassert (toc1 > toc2)

%!test
%! % By definition, the derivative of the meridian arc length
%! % with respect to latitude is the meridian radius of curvature.
%! % 
%! % Here we obtain the derivative numerically and analytically.
%! 
%! M = pi/180 * compute_meridian_radius (lat, ell);
%! 
%! M2 = diff_func (...
%!     @(lat) get_meridian_arclen (lat, ell), ...
%!     lat);
%! 
%! %lat
%! idx = (lat ~= 90);  % avoid border value
%! %[M(idx), M2(idx)], [M(idx) - M2(idx)]
%! %M(~idx), M2(~idx)
%! myassert (M(idx), M2(idx), -1e-3)

%!test
%! % values in excess of 90 (positive or negative) 
%! % should be handled in such a way that
%! % their derivative is correct:
%! lat = [+91; -91];
%! 
%! G1 = get_meridian_arc_length2 (lat, ell);
%! G2 = get_meridian_arclen  (lat, ell);
%! 
%! M1 = pi/180 * compute_meridian_radius (lat, ell);
%! M2 = diff_func (...
%!     @(lat) get_meridian_arclen (lat, ell), ...
%!     lat);
%! 
%! %lat
%! %[G1, G2], G2 - G1
%! myassert(G1, G2, -10*sqrt(eps))
%! %[M1, M2], M2 - M1
%! myassert(M1, M2, -1e-3)

