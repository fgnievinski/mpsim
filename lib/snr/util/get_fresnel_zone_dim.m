function [R, a, b] = get_fresnel_zone_dim (height, elev, wavelength, zone, form)
    if (nargin < 1) || isempty(height),  height = 1.5;  end
    if (nargin < 2) || isempty(elev),  elev = 15;  end
    if (nargin < 3),  wavelength = [];  end
    if (nargin < 4) || isempty(zone),  zone = 1;  end
    if (nargin < 5) || isempty(form),  form = 'correct';  end
    wavelength = get_gnss_wavelength(wavelength);
    sin_elev = sind(elev);
    tan_elev = tand(elev);
    d = fresnel2delay(zone, wavelength);
    R = height ./ tan_elev + (d ./ sin_elev) ./ tan_elev;  % = (height + d ./ sin_elev) ./ tan_elev;
    if (nargout < 2),  return;  end
    switch form
    case 'correct'
        % H. D. Hristov (2000), Fresnel zones in wireless links, zone plate
        % lenses and antennas, Artech House, ISBN 9780890068496, pp.323.
        % p.93-94, case 1 (or, equivalently, 2), eq. 3.15-3.17; notice typo
        % in eq.3.15, i.e., missing lambda (contrast with eq.3.18).
        b = sqrt( (2 .* d .* height ./ sin_elev) + (d ./ sin_elev).^2 );
        a = b ./ sin_elev;
    otherwise
        % Katzberg, S.J. and J. L. Garrison, Jr. (1996), Utilizing GPS To
        % Determine Ionospheric Delay Over the Ocean. NASA Technical
        % Memorandum 4750, Langley Research Center, Hampton, VA, USA.
        % Available at <http://hdl.handle.net/2060/19970005019>. NOTICE THE
        % ERRATA!!!
        b = sqrt(2 .* d .* height .* sin_elev) ./ sin_elev;
        a = b ./ sin_elev;
    end
end
