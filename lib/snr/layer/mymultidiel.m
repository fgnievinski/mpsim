function [Gamma_horz,Gamma_vert] = mymultidiel (l,eps,f,theta)
    c0 = get_standard_constant('speed of light');
    lambda = c0 / f;

    % from physics to engineering sign convention:
    eps = conj(eps);
    
    n = sqrt(eps);  % complex index of refraction.
    
    L = l(:) .* n(2:end-1);  % complex-valued optical thickness

    Gamma_TE = multidiel1(n,L,lambda,theta,'TE');
    Gamma_TM = multidiel1(n,L,lambda,theta,'TM');
    
    % back from engineering to physics sign convention:
    Gamma_TE = conj(Gamma_TE);
    Gamma_TM = conj(Gamma_TM);

    Gamma_TM = -Gamma_TM;
    % "Some references de?ne ?_TM with the opposite sign. Our convention was chosen because it has the expected limit at normal incidence."
    % p.248, chap.5 in Sophocles J. Orfanidis, "Electromagnetic Waves and Antennas"
    
    Gamma_horz = Gamma_TE;
    Gamma_vert = Gamma_TM;
    % As per Fig.3.2, p.116 in Shane Cloude, "Polarisation: applications in remote sensing", Oxford University Press, 2000. 453 pages. [http://books.google.com/books?id=gjbkvl0MJncC&lpg=PA234&dq=polarimetric%20interferometry&pg=PA116#v=onepage&q=parallel%20perpendicular&f=false]
    % perp  = horz = TE = p
    % paral = vert = TM = s
end
