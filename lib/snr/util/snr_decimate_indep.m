function [elevi, indepi, elev2indep, indep2elev] = snr_decimate_indep (indep_spacing, indep_type, elev_lim, varargin)
    if (nargin < 1),  indep_spacing = [];  end
    if (nargin < 2) || isempty(indep_type),  indep_type = 'sine';  end
    if (nargin < 3),  elev_lim = [];  end
    elev_lim_default = [0 90];
    indep_spacing_default = 2.5e-3;
    switch indep_type
    case 'elev'
        elev2indep = @itself;
        indep2elev = @itself;
        indep_spacing_default = 1;  % in degrees
    case {'sine','sinelev'}
        elev2indep = @sind;
        indep2elev = @asind;
    case {'sinesq','sin-elev squared'}
        elev2indep = @(elev) sind(elev).^2;
        indep2elev = @(indep) asind(sqrt(indep));
    case {'sinesqrt','sin-elev square-root'}
        elev2indep = @(elev) sqrt(sind(elev));
        indep2elev = @(indep) asind(indep.^2);
    case {'sinenthroot','sin-elev nth-root'}
        n = varargin{1};
        elev2indep = @(elev) nthroot(sind(elev), n);
        indep2elev = @(indep) asind(indep.^n);
    case {'cote','cotane','cotan'}
        elev2indep = @cotd;
        indep2elev = @acotd;
        elev_lim_default = [1 90];
    case {'dist','distance'}
        height = varargin{1};
        % see get_fresnel_zone_dim.m and get_specular_point.m:
        elev2indep = @(elev) height ./ tand(elev);
        indep2elev = @(indep) atand(height ./ indep);
        elev_lim_default = [1 90];
        indep_spacing_default = 1;  % in meters
    otherwise
        error('snr:snr_decimate:badVarKind', 'Unknown var_kind = "%s".', ...
            indep_type);
    end
    
    if isempty(elev_lim),  elev_lim = elev_lim_default;  end
    indep_lim = elev2indep(elev_lim);
    
    if isempty(indep_spacing),  indep_spacing = indep_spacing_default;  end
    if ischar(indep_spacing),  indep_spacing = indep_spacing_default * str2double(indep_spacing);  end
    
    indep_spacing = indep_spacing * sign(diff(indep_lim));    
    indepi = (indep_lim(1):indep_spacing:indep_lim(2))';
    elevi = indep2elev(indepi);
end

