function [indep_fnc, height2phaserate, indep_type] = snr_bias_indep_aux (indep_type, wavelength)
    if (nargin < 2),  wavelength = [];  end
    indep_type_default = 'sine';  % better conditioned inversion.
    %indep_type_default = 'vertwavenum';  % unity height2phaserate.
    if isempty(indep_type),  indep_type = indep_type_default;  end
    wavenumber = 2*pi./wavelength;
    wavenumber = wavenumber * 180/pi;  % was in rad/m, now it's in deg/m.    
    switch indep_type
    case {'zen','zenith angle'}
        indep_fnc = @(elev, graz) 90 - elev;
        height2phaserate = NaN;
    case {'elev','elevation angle'}
        indep_fnc = @(elev, graz) elev;
        height2phaserate = NaN;
    case {'sine','sine of elevation angle'}
        indep_fnc = @(elev, graz) sind(elev);
        height2phaserate = 2*wavenumber;
    case {'vertwavenum','vertical wavenumber'}
        indep_fnc = @(elev, graz) 2*wavenumber*sind(elev);
        height2phaserate = 1;
    case {'sing','sine of grazing angle'}
        indep_fnc = @(elev, graz) sind(graz);
        height2phaserate = 2*wavenumber;
    case {'nrmlwavenum','normal wavenumber'}
        indep_fnc = @(elev, graz) 2*wavenumber*sind(graz);
        height2phaserate = 1;
    otherwise
        error('snr:bias:badVar', 'Unknown indep_var = "%s".', indep_type);
    end
end

