function ant = snr_setup_ant (sett_ant, freq_name, channel, ignore_vec_apc_arp)
    ant = sett_ant;  clear sett_ant
    if isempty(ant.radome),  ant.radome = 'NONE';  end
    ant.radome = upper(ant.radome);
    ant.model = upper(ant.model);
    
    ant.model = snr_setup_ant_synonym (ant.model);
    ant = snr_setup_ant_char (ant);
    
    %wavelength = get_gnss_wavelength (freq_name);  % WRONG!
    wavelength = get_gnss_wavelength (freq_name, channel);
    [ant.eff_area_iso, ant.eff_len_norm_iso] = snr_setup_ant_area (wavelength);
    
    [ant.rot, ant.dir_nrml] = get_rotation_matrix3_local (...
        ant.slope, ant.aspect, ant.axial);
    %ant.rot, ant.dir_nrml, ant.slope, ant.aspect, ant.axial  % DEBUG

    ant.snr_fwd_direction_local2ant = @snr_fwd_direction_local2ant;
    
    ant.vec_apc_arp_upright = NaN(1,3);
    if isempty(ignore_vec_apc_arp),  ignore_vec_apc_arp = false;  end
    if ~ignore_vec_apc_arp
        ant.vec_apc_arp_upright = snr_setup_ant_offset (...
            ant.model, ant.radome, freq_name);
    end

    [ant.gain, ant.phase] = snr_setup_ant_pattern (...
        ant.model, ant.radome, freq_name, ...
        ant.sph_harm_degree, ant.load_redundant, ant.switch_left_right, ...
        ant.load_extended);
        
    ant = get_antenna_pattern_fnc (ant);
    ant = get_antenna_phase_aux (ant);
    
    ant.gain.rhcp.boresight = ant.gain.eval(90, 0, 'rhcp');
    ant.gain.lhcp.boresight = ant.gain.eval(90, 0, 'lhcp');
end

%%
function ant = snr_setup_ant_char (ant)
    if ischar(ant.slope),  switch lower(ant.slope) %#ok<ALIGN>
    case 'upright'
        ant.slope = 0;
    case {'tipped','sideways'}
        ant.slope = 90;
    case {'upside-down','flipped'}
        ant.slope = 180;
    otherwise
        error('snr:snr_setup_ant:badSlopeChar', ...
            'Unknown non-numeric antenna slope "%s".', ant.slope);
    end,  end
    if ischar(ant.aspect),  switch lower(ant.aspect) %#ok<ALIGN>
    case 'north'
        ant.aspect = 0;
    case 'east'
        ant.aspect = 90;
    case 'south'
        ant.aspect = 180;
    case 'west'
        ant.aspect = 270;
    otherwise
        error('snr:snr_setup_ant:badAspectChar', ...
            'Unknown non-numeric antenna aspect "%s".', ant.aspect);
    end,  end
    if ischar(ant.axial)
        error('snr:snr_setup_ant:badAxialChar', ...
            'Non-numeric antenna axial rotation "%s".', ant.axial);
    end
end  

%%
function ant = get_antenna_phase_aux (ant)
    %is_constant_defined = ~isempty(ant.rhcp_phase) && ~isempty(ant.polar_phase);
    is_constant_defined = ~isempty(ant.rhcp_phase) || ~isempty(ant.polar_phase);
    is_pattern_available = ~isfieldempty(ant, 'phase', 'eval');
    
    if ~is_pattern_available && is_constant_defined
        use_constant = true;
    elseif is_pattern_available && ~is_constant_defined
        use_constant = false;
    elseif ~is_pattern_available && ~is_constant_defined
        use_constant = true;
    elseif is_pattern_available && is_constant_defined
        warning('snr:ant:phase', ...
            ['Non-empty input antenna phase values defined; '...
             'ignoring antenna phase pattern available.'])
        use_constant = true;
    end
  
    if ~use_constant,  return;  end

    if isempty(ant.rhcp_phase),   ant.rhcp_phase  = 0;   end
    if isempty(ant.polar_phase),  ant.polar_phase = 90;  end

    ant.phase.rhcp = ant.rhcp_phase;
    ant.phase.lhcp = ant.polar_phase + ...
    ant.phase.rhcp; 
    ant.phase.eval = @(elev, azim, polar) repmat(ant.phase.(polar), size(elev));
end

%%
function [eff_area_iso, eff_len_norm_iso] = snr_setup_ant_area (wavelength)
    eff_area_iso = wavelength^2 / (4*pi);  % in m^2.
    %eff_area = ant.eff_area_iso * ant_power_total;  % ant_power_total not available now.
    impedance0 = get_standard_constant('impedance of free space');
    impedance = 50;  % in ohms
    % "practically all GPS front-end components utilize an impedance of 50
    % ohms" p.55 in A software-defined GPS and Galileo receiver: a
    % single-frequency approach By Kai Borre, Dennis M. Akos, Nicolaj
    % Bertelsen, Peter Rinder, Soren Holdt Jensen
    eff_len_norm_iso = 2 * sqrt(eff_area_iso * impedance / impedance0);  % in meters.
    %eff_len_norm = 2 * sqrt(eff_area * impedance / impedance0);
end
