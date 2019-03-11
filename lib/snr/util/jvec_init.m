function [phasor_rhcp, phasor_lhcp] = jvec_init (...
magnitude, polar_power, polar_phase)
    if (nargin < 1) || isempty(magnitude),  magnitude = 1;  end
    if (nargin < 2) || isempty(polar_power),  polar_power = 0;  end
    if (nargin < 3) || isempty(polar_phase),  polar_phase = 0;  end
    polar_magn = sqrt(polar_power);
    %magnitude_rhcp = magnitude ./ (1 + polar_magn);
    %magnitude_lhcp = magnitude ./ (1 + polar_magn^-1);
    %  myassert(magnitude_lhcp, magnitude_rhcp*polar_magn, -eps);
    %  myassert(magnitude_lhcp + magnitude_rhcp, magnitude, -eps);
    % The definition below (above) keeps the RHCP (total) power independent
    % of the polarization ellipticity; since typically the composite signal
    % is predominantly RHCP, only the definition below keeps the SNR trend 
    % mostly insentive to polarization ellipticity, which is preferable to 
    % the definition above, which causes both the trend and the interference 
    % pattern to change with ellipticity.  Furthermore, only the definition 
    % below is consistent with routine convert_polar_ellipticity_alphadb2beta.m.
    magnitude_rhcp = magnitude;
    magnitude_lhcp = magnitude_rhcp .* polar_magn;
    phase_rhcp = 0;  % arbitrary.
    phase_lhcp = phase_rhcp + polar_phase;
    phasor_rhcp = phasor_init (magnitude_rhcp, phase_rhcp);
    phasor_lhcp = phasor_init (magnitude_lhcp, phase_lhcp);
    %disp(polar_magn)  % DEBUG
end

