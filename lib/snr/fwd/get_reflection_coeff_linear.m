function [phasor_perp, phasor_paral] = get_reflection_coeff_linear (...
elev_incid, perm_bottom, perm_top)
    if (nargin < 3) || isempty(perm_top),  perm_top = complex(1, 0);  end
    ang = 90 - elev_incid;  % ang. of incidence w.r.t. sfc normal.
    cos_ang = cosd(ang);
    sin_ang_sq = sind(ang).^2;
    R_bottom = perm_bottom;
    R_top    = perm_top;
    R_ratio = R_bottom ./ R_top;
    %phasor_paral = ...
    %    ( R_bottom .* cos_ang - R_top .* sqrt(R_ratio - sin_ang_sq) ) ./ ...
    %    ( R_bottom .* cos_ang + R_top .* sqrt(R_ratio - sin_ang_sq) );
    %phasor_paral = ...
    %    ( R_ratio .* cos_ang - sqrt(R_ratio - sin_ang_sq) ) ./ ...
    %    ( R_ratio .* cos_ang + sqrt(R_ratio - sin_ang_sq) );
    %phasor_perp = ...
    %    (            cos_ang - sqrt(R_ratio - sin_ang_sq) ) ./ ...
    %    (            cos_ang + sqrt(R_ratio - sin_ang_sq) );
    temp = sqrt(R_ratio - sin_ang_sq);
    phasor_paral = (R_ratio .* cos_ang - temp) ./ ...
                   (R_ratio .* cos_ang + temp);
    phasor_perp  = (           cos_ang - temp) ./ ...
                   (           cos_ang + temp);
    % see Beckmann & Spizzichino, eq.(13)-(14), p.21.
    % also Vaughan and Andersen, eq.(3.1.19)-(3.1.20), p.93.
    % and Shane Cloude, eq.(3.5), p.118.
    % 
    % As per Fig.3.2, p.116 in Shane Cloude, "Polarisation: applications in
    % remote sensing", Oxford University Press, 2000. 453 pages.
    % <http://books.google.com/books?id=gjbkvl0MJncC&lpg=PA234&dq=polarimetric%20interferometry&pg=PA116#v=onepage&q=parallel%20perpendicular&f=false>
    % perp  = horz = TE = p
    % paral = vert = TM = s
    
    %[phasor_perp, phasor_paral] = deal(phasor_paral, phasor_perp);  % DEBUG
    %phasor_paral = abs(phasor_paral).*get_phase_inv(get_phase(phasor_paral)+180);  % DEBUG
end

