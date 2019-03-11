function [perm, freq] = get_permittivity (material, freq, extra, sanitize, convention)
%GET_PERMITTIVITY:  Return electric permittivity of a given material.
% 
% SYNTAX:
%    get_permittivity ()
%    get_permittivity ('all')
%    perm = get_permittivity (material)
%    perm = get_permittivity (material, freq)
%    perm = get_permittivity (material, freq, extra)
%
% INPUT:
%    material: [char] material name ('asphalt', 'copper', etc.)
%    material: [structure] material definition with at least the field 'name';
%      optionally it contains also the extra fields described below.
%    material: [cell] an array of materials, each defined as above
%    freq: [scalar] desired electromagnetic frequency (in hertz)
%    freq: [char] desired electromagnetic frequency band ('L1','L2,'L5')
%    extra: [structure] extra information required by certain material models
%    if name = 'soil':
%      .type: [char] soil type ('sandy loam', 'loam', 'silt loam 1', 'silt loam 2', 'silty clay')
%      .moisture: [scalar] volumetric soil moisture (in cubic meter per cubic meter)
%    if name = 'snow':
%      .density: [scalar] snow density (relative to that of liquid water; equivalently, in g/cm^3)
%      .temperature: [scalar] snow temperature (in degree Celsius)
%
% OUTPUT:
%    perm: [scalar] the material permittivity (complex-valued)
%    perm: [vector] the materials permittivities (complex-valued)
%
% EXAMPLES:
%    perm = get_permittivity ('zinc')
%    perm = get_permittivity ('soil', 'L2', struct('type','loam', 'moisture',0.5))
%    perm = get_permittivity (struct('name','snow', 'temperature',-2, 'density',0.25))
%    perm = get_permittivity ({'grass'; 'air'}, get_gnss_frequency('L1'))
%    perm = get_permittivity ({'vacuum'; struct('name','arbitrary conductivity', 'cond',10)})
%
% REMARKS:
% - A call with no input arguments or with 'all' as single input argument will produce a list of known materials.
% - Multiple materials can be retrieved simultaneously via cell-array input.
% 
% SEE ALSO: get_reflection_coeff

    %%
    %if (nargin < 1) || isempty(first_arg),  first_arg = 'all';  end  % WRONG!
    if (nargin < 1),  material = 'all';  end
    if (nargin < 2),  freq = [];  end
    if (nargin < 3),  extra = [];  end
    if (nargin < 4) || isempty(sanitize),  sanitize = false;  end
    if (nargin < 5),  convention = [];  end
    if ischar(material) && any(strcmpi(material, {'list', 'all', 'materials'}))
        name = get_permittivity_name_list ();
        name(strstart('arbitrary', name)) = [];
        name(strstart('hannah', name)) = [];
        if (nargout == 0),  perm = name;  return;  end
        perm = cellfun(@get_permittivity, name);
        if ~is_octave(),  cprintf(perm, '-Lr',name);  end
        clear perm
        return
    elseif isstruct(material)
        material_name = material.name;
        extra = material;
    else
        material_name = material;
    end
    freq = get_gnss_frequency(freq);
    [perm, freq] = get_permittivity_aux (material_name, freq, extra, ...
        sanitize, convention);
end

%%
function temp2 = get_permittivity_name_list ()
    temp0 = fileread(which(mfunctionname()));
    temp0(temp0 == sprintf('\r')) = [];
    temp1 = regexp(temp0, '[\n]    case {?([^}\n]*)', 'tokens')';
    temp2 = cellfun(@cell2mat, temp1, 'UniformOutput',false);
    temp2 = strtok(temp2,',');
    temp2 = strrep(temp2, '''','');
    temp2(cellfun(@isempty,temp2)) = [];
    %temp2 = flipud(sort(temp2)); %#ok<FLPST> not applicable for cells
end
        
%%
function [perm, freq] = get_permittivity_aux (material_name, freq, extra, sanitize, convention)
    if iscell(material_name)
        [perm, freq] = cellfun(@(material_name) get_permittivity (...
            material_name, freq, extra, sanitize), material_name);
        return;
    end
    
    [perm_real, perm_imag, cond, freq] = get_permittivity_components (...
        material_name, freq, extra, sanitize);
    
    if isempty(perm_imag)
        perm_imag = convert_conductivity_to_pemittivity (cond, freq);
    end
    perm = permittivity_realimag2complex (perm_real, perm_imag, convention);
end

%%
function [perm_real, perm_imag, cond, freq] = get_permittivity_components (...
material_name, freq, extra, sanitize)
    assert(isempty(extra) || isstruct(extra))
    perm_imag = [];
    cond = [];
    freq_min = -Inf;  freq_max = +Inf;
    freq_min_itu = 1e9;  freq_max_itu = 2e9;
    interp1lerploglog = @(x, y, xi) exp(interp1lerp(log(x), log(y), log(xi)));
    interp1itu = @(cond_min, cond_max) interp1lerploglog(...
        [freq_min_itu freq_max_itu], [cond_min cond_max], freq);
    cond_copper = get_standard_constant('copper conductivity');
    switch strrep(lower(char(material_name)), '_',' ')
    case ''
        perm_real = [];
        perm_imag = [];
    case {'arbitrary complex','arbitrary'}
        perm = extra.perm;
        [perm_real, perm_imag] = permittivity_complex2realimag (perm);
    case {'arbitrary real imag diff','arbitrary real imaginary difference'}
        perm_real = extra.perm_real;
        perm_imag = extra.perm_imag;
        perm_real = permittivity_realdiff (perm_real);
    case {'arbitrary real imag','arbitrary real imaginary','real/imag'}
        perm_real = extra.perm_real;
        perm_imag = extra.perm_imag;
        if sanitize
            idx = (perm_real < 1);
            if any(idx)
                warning('snr:get_permittivity:outOfRange', ...
                    'Real permittivity smaller than unity detected; assuming unity.');
                perm_real(idx) = 1;
            end
            idx = (perm_real < 0);
            if any(idx)
                warning('snr:get_permittivity:outOfRange', ...
                    'Negative imaginary permittivity smaller than zero detected; assuming zero.');
                perm_imag(idx) = 0;
            end
        end
    case {'arbitrary magn phase','arbitrary magnitude phase','magn/phase'}
        perm_magn  = extra.perm_magn;
        perm_phase = extra.perm_phase;
        idx = (perm_magn < 1);
        if sanitize
            if any(idx)
                warning('snr:get_permittivity:outOfRange', ...
                    'Permittivity magnitude smaller than unity detected; assuming unity.');
                perm_magn(idx) = 1;
            end
            idx = (perm_phase < 0);
            if any(idx)
                warning('snr:get_permittivity:outOfRange', ...
                    'Negative permittivity phase detected; assuming zero.');
                perm_phase(idx) = 0;
            end
        end
        perm = permittivity_magnphase2complex (perm_magn, perm_phase);
        [perm_real, perm_imag] = permittivity_complex2realimag (perm);
    case {'arbitrary real cond','arbitrary real and conductivity'}
        perm_real = extra.perm_real;
        cond = extra.cond;
    case 'arbitrary conductivity'
        perm_real = 0;
        cond = extra.cond;
    case 'vacuum'
        perm_real = 1;
        perm_imag = 0;
        % by definition.
    case 'air'
        perm_real = 1.00058986;  % +/- 0.00000050, at STP only!
        perm_imag = 0;
        % from L. G. Hector and H. L. Schultz (1936), The Dielectric
        % Constant of Air at Radiofrequencies, Physics, Vol. 7, No. 4,
        % p.133-136; doi:10.1063/1.1745374. If necessary, values of
        % relative permittivity of air for specific atmospheric conditions
        % (i.e., pressure, temperature, and humidity) and frequencies,
        % start from models for refractivity (N = 10^6 * (n - 1)) of air
        % then use the definition of index of refraction (n^2 = mu_r *
        % epsilon_r). For relative permeability of air, mu_r, you can use
        % the value 1.000,000,37 = 1+0.37e-6 (B. D. Cullity and C. D.
        % Graham (2008), Introduction to Magnetic Materials, 2nd edition,
        % 568 pp., p.16), which, besides being very similar to that of
        % vacuum, presumably is not very variable. For refractivity at
        % radio frequencies, see, e.g., Rueger, J. M. (2002). "Refractive
        % index formulae for radio waves." FIG XXII International Congress,
        % International Federation of Surveyors (FIG),Washington, D.C.,
        % April 19-26,
        % <http://www.fig.net/pub/fig_2002/Js28/JS28_rueger.pdf>.
    case 'grass'
        perm_real = 3.7;
        cond = 0.08;
        freq_min = 1e9;
        freq_max = 2e9;
        % used in Kavak, Vogel, and Xu (1998), "Using GPS to measure ground
        % complex permittivity", from Lytle (1974) "Measurement of earth
        % medium electrical characteristics: techniques, results and
        % applications".
    case 'asphalt'
        perm_real = 2;
        cond = 0.03;
        freq_min = 1e9;
        freq_max = 2e9;
        % used in Kavak, Vogel, and Xu (1998), "Using GPS to measure ground
        % complex permittivity", from Lytle (1974) "Measurement of earth
        % medium electrical characteristics: techniques, results and
        % applications".
    case 'polystyrene'
        perm_real = 2.55;
        perm_imag = 8.67e-4;
        freq_min = get_gps_freq ('L1');
        freq_max = freq_min;
        % used in Jacobson (2008), "Dielectric-covered ground reflectors in
        % GPS multipath reception -- Theory and measurement", from von
        % Hippel (1958) "Dielectric materials and applications: Tables of
        % dielectric materials", vol.V.
    case 'styrofoam'
        perm_real = 1.03;
        perm_imag = 1.03e-4;
        freq_min = get_gps_freq ('L1');
        freq_max = freq_min;
        % used in Jacobson (2008), "Dielectric-covered ground reflectors in GPS multipath reception -- Theory and measurement", from von Hippel (1958) "Dielectric materials and applications: Tables of dielectric materials", vol.V.
    case {'dry snow fixed', 'snow'}
        perm_real = 1.48;
        perm_imag = 2.76e-4;
        freq_min = get_gps_freq ('L2');
        freq_max = get_gps_freq ('L1');
        % used in Fig. 4 of Jacobson (2008), "Dielectric-covered ground
        % reflectors in GPS multipath reception -- Theory and measurement"
    case 'dry snow'
        [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_snow (...
            freq, extra, sanitize);
    case {'soil','ground'}
        [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_soil (...
            freq, extra, sanitize);
    case {'soil default','ground default'}
        extra_default = struct('moisture','default', 'type','default');
        %extra = structmergenonempty(extra, extra_default);  % WRONG!
        extra = structmergenonempty(extra_default, extra);
        [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_soil (...
            freq, extra, sanitize);
    case {'seawater variable','variable seawater'}
        [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_seawater_variable (...
            freq, extra, sanitize);
    % The next cases are taken from Tab. 2.1 in :
    %   B. M. Hannah (2001), Modelling and simulation of GPS multipath
    %   propagation, PhD thesis, Queensland University of Technology, 375
    %   pp. Available at <http://eprints.qut.edu.au/15782/>.
    % The original cited source is:
    %   ITU-R, "Electrical characteristics of the surface of the Earth", 
    %   Recommendation Rec. 527-3.
    % The stated frequency of validity is 1 GHz. The sign convention is 
    %   complex perm. = real perm. - imag. perm.
    % 
    % Later I have have found some discrepancies consulting the original:
    %   ITU-R (1992) "Recommendation ITU-R P.527-3: Electrical
    %   characteristics of the surface of the Earth", International
    %   Telecommunication Union, Radiocommunication Study Group 3, 
    %   Radiowave Propagation Series, Volume 2000, Part 1. Available at
    %   <http://www.itu.int/rec/R-REC-P.527/>
    % ITU's original values were entered, retainning Hannah's values when 
    % different, as they have been in use for some years. Also, the 
    % frequency of validity is larger in the original source. Finally, 
    % conductivity was found to vary log-linearly in the L band, so now 
    % it is frequency-dependent.
    case {'seawater','seawater fixed','itu seawater average'}
        perm_real = 70;
        cond = interp1itu(5, 6);  % @ T = +20°C and average salinity
        freq_min = freq_min_itu;
        freq_max = freq_max_itu;
    case 'hannah seawater'
        perm_real = 20;  cond = 4;  freq_min = 1e9;  freq_max = freq_min;
    case {'wet soil','wet soil fixed','itu wet soil',...
          'wet ground','wet ground fixed','itu wet ground'}  % ITU B
        perm_real = 30;
        cond = interp1itu(0.15, 4);
        freq_min = freq_min_itu;
        freq_max = freq_max_itu;
    case {'hannah wet soil','hannah wet ground'}
        perm_real = 30;  cond = 2e-1;  freq_min = 1e9;  freq_max = freq_min;
    case {'freshwater','itu freshwater'}  % ITU C
        perm_real = 80;
        cond = interp1itu(0.175, 7);
        freq_min = freq_min_itu;
        freq_max = freq_max_itu;
    case 'hannah freshwater'
        perm_real = 80;  cond = 2e-1;  freq_min = 1e9;  freq_max = freq_min;
    case {'dry/wet soil','average soil','medium soil','soil fixed','itu medium dry/wet soil',...
          'dry/wet ground','average ground','medium ground','ground fixed',...
          'itu medium dry/wet ground','medium dry/wet ground'}  % ITU D
        perm_real = 15;
        cond = interp1itu(3.5e-2, 0.125);
        freq_min = freq_min_itu;
        freq_max = freq_max_itu;
    case {'hannah medium dry/wet soil','hannah medium dry/wet ground'}
        perm_real = 7;  cond = 4e-2;  freq_min = 1e9;  freq_max = freq_min;
    case {'dry ground','dry ground fixed','itu dry ground',...
          'dry soil','dry soil fixed','itu dry soil'}  % ITU E
        perm_real = 3;
        cond = interp1itu(1.5e-4, 7.5e-4);
        freq_min = freq_min_itu;
        freq_max = freq_max_itu;
    case {'hannah dry ground','hannah dry soil'}
        perm_real = 4;  cond = 1e-5;  freq_min = 1e9;  freq_max = freq_min;
    %case 'itu concrete'  % non-existent.
    case {'concrete','hannah concrete'}
        perm_real = 3;  cond = 2e-5;  freq_min = 1e9;  freq_max = freq_min;
    %case 'hannah ice'  % non-existent.
    case {'ice','itu ice'}  % ITU G
        [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_ice (...
            freq, extra, sanitize, interp1itu, freq_min_itu, freq_max_itu);
%     case 'hardware cloth'
%        % a welded steel wire mesh galvanized with a zinc coating
%        % <http://www.twpinc.com/twp/jsp/wireMeshInformation.jsp#GalvanizedHardwareClothTechnicalInformation>
%         [perm_real, perm_imag, cond] = get_permittivity_components (...
%             'steel', freq, extra);  % ASSUMED!
%         return
    case 'steel'
        %perm_real = 1000;  % WRONG! that was (magnetic) permeability!
        perm_real = 0;
        cond = 0.10 * cond_copper;
        freq_min = NaN;
        freq_max = NaN;
        % Tab.5.1, p.301, in C. R. Paul, "Introduction to electromagnetic
        % compatibility", 2006, 2nd edition, John Wiley and Sons, 983 pp.,
        % ISBN 9780471755005.
    case 'zinc'
        perm_real = 0;
        cond = 0.32 * cond_copper;
        freq_min = NaN;
        freq_max = NaN;
        % Tab.5.1, p.301, in C. R. Paul, "Introduction to electromagnetic
        % compatibility", 2006, 2nd edition, John Wiley and Sons, 983 pp.,
        % ISBN 9780471755005.
    case 'aluminum'
        perm_real = 0;
        cond = 0.61 * cond_copper;
        freq_min = NaN;
        freq_max = NaN;
        % Tab.5.1, p.301, in C. R. Paul, "Introduction to electromagnetic
        % compatibility", 2006, 2nd edition, John Wiley and Sons, 983 pp.,
        % ISBN 9780471755005.
    case 'copper'
        perm_real = 0;
        cond = cond_copper;
        freq_min = NaN;
        freq_max = NaN;
        % Tab.5.1, p.301, in C. R. Paul, "Introduction to electromagnetic
        % compatibility", 2006, 2nd edition, John Wiley and Sons, 983 pp.,
        % ISBN 9780471755005.
    case {'perfect electric conductor','pec','metal'}
        perm_real = 0;
        %cond = Inf();  % was leading to NaN.
        %cond = realmax();  % was leading to overflow.
        cond = sqrt(realmax());
        freq = 1;  % so that cond/freq is defined.
        freq_min = NaN;
        freq_max = NaN;
    otherwise
        error('snr:get_permittivity:badMaterialName', ...
            'Unknown material name "%s".', lower(material_name));
    end

    % have only perm_imag or cond, not both (unless perm_real is also missing):
    myassert(xor(isempty(perm_imag), isempty(cond)) || isempty(perm_real))
    assert(freq_min <= freq_max || isnan(freq_min) || isnan(freq_max))

    %if ~isempty(freq) && ( (freq < freq_min-eps()) || (freq > freq_max+eps()) )
    %    warning('snr:get_permittivity:badFreq', ...
    %    ['Frequency requested (%g Hz) outside of known limits of validity '...
    %     '(%g Hz to %g Hz) for "%s" permittivity.'], ...
    %     freq, freq_min, freq_max, material_name);
    %end
end

%%
function msg = get_warning_msg_extra_empty (fn, val, un)
  if ischar(val),  valt = val;  else  valt = sprintf('%g', val);  end
  unt = '';  if (nargin > 2) && ~isempty(un),  unt = [' (units: ' un ')'];  end
  msg = sprintf(['Empty %s; assuming default %s%s' ...
             '\n(input string literal ''default'' to ignore).'], fn, valt, unt);
end

%%
function [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_seawater_variable (...
freq, extra, sanitize)
    salinity_default = 35;   salinity_units = 'parts-per-thousand';
    temperature_default = 20;  temperature_units = 'degrees Celsius';
    if isfieldempty(extra, 'salinity')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'seawater salinity', salinity_default, salinity_units));
        extra.salinity = 'default';
    end
    if isfieldempty(extra, 'temperature')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'seawater temperature', temperature_default, temperature_units));
        extra.temperature = 'default';
    end
    if strcmpi(extra.salinity, 'default'),  extra.salinity = salinity_default;  end
    if strcmpi(extra.temperature, 'default'),  extra.temperature = temperature_default;  end
    if sanitize
        idx = (extra.salinity < 0);
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Negative seawater salinity detected; assuming default.');
            extra.salinity(idx) = salinity_default;
        end
        idx = (extra.salinity > 260);  % "At 0°C, brine can only hold about 26% salt."
        % <https://en.wikipedia.org/wiki/Brine>
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Seawater salinity greater than 260 parts-per-thousand detected; assuming default.');
            extra.salinity(idx) = salinity_default;
        end
    end
    perm_real = real(get_permittivity('seawater fixed', freq));
    cond = 0.18*extra.salinity.^0.93*(1+0.02.*(extra.temperature-20));
    % ITU-R, eq.(1), in <http://www.itu.int/dms_pubrec/itu-r/rec/p/R-REC-P.527-3-199203-I!!PDF-E.pdf>
    perm_imag = convert_conductivity_to_pemittivity (cond, freq);
    freq_min = NaN;
    freq_max = 1e9;
    warning('snr:get_permittivity:seawater_bad', ...
        ['Material "variable seawater" not necessarily valid '...
         'for L band (valid only at frequencies below 1 GHz)!']);
end

%%
function [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_ice (...
freq, extra, sanitize, interp1itu, freq_min_itu, freq_max_itu)
    temperature_default = -10;  temperature_units = 'degrees Celsius';
    if isfieldempty(extra, 'temperature')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'ice temperature', temperature_default, temperature_units));
        extra.temperature = 'default';
    end
    if strcmpi(extra.temperature, 'default'),  extra.temperature = temperature_default;  end
    if sanitize
        idx = (extra.temperature > 0);
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Positive ice temperature detected; assuming default.');
            extra.temperature(idx) = temperature_default;
        end
    end
    perm_real = 3;
    conda = interp1itu(2.5e-4, 4.5e-4);  tempa = -10;  % °C
    if all(extra.temperature == -10)
        cond = conda;
    else
        condb = interp1itu(8.5e-4, 1.5e-3);  tempb = -1;  % °C
        cond = NaN(size(conda));
        cond(:) = interp1lerp([tempa tempb], [conda(:) condb(:)], extra.temperature);
    end
    perm_imag = convert_conductivity_to_pemittivity (cond, freq);
    freq_min = freq_min_itu;
    freq_max = freq_max_itu;
end

%%
function [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_soil (...
freq, extra, sanitize) %#ok<INUSL>
    moisture_default = 0.3;
    type_default = 'silty clay';
    if isfieldempty(extra, 'moisture')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'soil moisture', moisture_default));
        extra.moisture = 'default';
    end
    if isfieldempty(extra, 'type')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'soil type', type_default));
        extra.type = 'default';
    end
    if strcmpi(extra.type, 'default'),  extra.type = type_default;  end
    if strcmpi(extra.moisture, 'default'),  extra.moisture = moisture_default;  end
    if isfieldempty(extra, 'interp_method')
        %extra.interp_method = 'cubic';  % WRONG!
        extra.interp_method = 'linear';  % more conservative in extrap.
    end
    if sanitize
        idx = (extra.moisture < 0);
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Negative soil moisture detected; assuming zero.');
            extra.moisture(idx) = 0;            
        end
        idx = (extra.moisture > 1);
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Soil moisture greater than 1.0 detected; assuming 1.0.');
            extra.moisture(idx) = 1;
        end
    end
    perm2 = permittivity_soil_setup();
    perm_type = {'real', 'imag'};
    perm = struct();
    for j=1:2
        %j  % DEBUG
        k = find(strcmp({perm2.(perm_type{j}).type}, extra.type));
        if isempty(k)
            error('snr:get_permittivity:Extra', ...
                'Unknown soil type = "%s";\ntry %s.', extra.type, ...
                getel(sprintf(', "%s"', perm2.real.type), '3:end'));
        end
        perm.(perm_type{j}) = interp1(...
            perm2.(perm_type{j})(k).moisture, ...
            perm2.(perm_type{j})(k).value, ...
            extra.moisture(:), extra.interp_method, 'extrap');
        idx = ~(extra.moisture < 0);
        perm.(perm_type{j}) = reshape(perm.(perm_type{j}), size(extra.moisture));
        if any(sign(perm.(perm_type{j})(:)) ~= mode(sign(perm2.(perm_type{j})(k).value(:)))) ...
        &&(any(extra.moisture(idx) < min(perm2.(perm_type{j})(k).moisture)) ...
        || any(extra.moisture(idx) > max(perm2.(perm_type{j})(k).moisture)))
    %                 figure
    %                   hold on
    %                   plot(perm2.(perm_type{j})(k).moisture, perm2.(perm_type{j})(k).value, 'o-k')
    %                   plot(extra.moisture, perm.(perm_type{j}), '.r')
    %                   xlabel('Soill moisture (VWC)')
    %                   ylabel(sprintf('%s permittivity', perm_type{j}))
            %error('snr:get_permittivity:soilExtrap', ...
            warning('snr:get_permittivity:soilExtrap', ...
                'Wrong sign found while extrapolating %s permittivity for soil type "%s".', ...
                perm_type{j}, extra.type);
        end
    end
    perm_real = perm.real;
    perm_imag = perm.imag;
    freq_min = get_gps_freq ('L2');
    freq_max = get_gps_freq ('L1');
end

%%
function [perm_real, perm_imag, freq_min, freq_max] = get_permittivity_snow (...
freq, extra, sanitize)
    density_default = 0.25;
    temperature_default = 0;
    % legacy interface:
    if isfield(extra, 'rho')
        warning('snr:get_permittivity:snowDeprecated', ...
            'Deprecated syntax; use field "density" instead of "rho".');
        extra.density = extra.rho;
    end
    if isfield(extra, 'T')
        warning('snr:get_permittivity:snowDeprecated', ...
            'Deprecated syntax; use field "temperature" instead of "T".');
        extra.temperature = extra.T;
    end
    if isfieldempty(extra, 'density')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'snow density', density_default));
        extra.density = 'default';
    end
    if isfieldempty(extra, 'temperature')
        warning('snr:get_permittivity:Extra', get_warning_msg_extra_empty (...
          'snow temperature', temperature_default));
        extra.temperature = 'default';
    end
    if strcmpi(extra.density, 'default'),  extra.density = density_default;  end
    if strcmpi(extra.temperature, 'default'),  extra.temperature = temperature_default;  end
    % Relative density of dry snow (compared to liquid water):
    % (or, equivalently, in multiples of 1000 kg/m^3)
    density = extra.density;
    % Temperature of snow (in degree Celsius):
    temperature = extra.temperature;
    if sanitize
        idx = (density < 0);
        if any(idx)
            warning('snr:get_permittivity:outOfRange', ...
                'Negative snow density detected; assuming zero.');
            density(idx) = 0;
        end
    end
    %perm_real = 1 + 2 * rho;
    perm_real = 1 + 1.7 * density + 0.7 * density.^2;
    perm_imag = 1.59e6 * (0.52 * density + 0.62 * density.^2) ...
        .* (freq.^(-1) + 1.23e-14 * sqrt(freq)) .* exp(0.036 .* temperature);
    freq_min = get_gps_freq ('L2');
    freq_max = get_gps_freq ('L1');;
    % used in Jacobson (2008), originally from Tiuri et al. (1984).
    %  Jacobson, M.D.; , "Dielectric-Covered Ground Reflectors in GPS
    %    Multipath Receptionï¿½Theory and Measurement," IEEE Geoscience
    %    and Remote Sensing Letters, vol.5, no.3, pp.396-399, July
    %    2008, doi: 10.1109/LGRS.2008.917130 
    %  Tiuri, M.; Sihvola, A.; Nyfors, E.; Hallikaiken, M.; , "The
    %    complex dielectric constant of snow at microwave frequencies,"
    %    IEEE Journal of Oceanic Engineering, vol.9, no.5, pp. 377- 382,
    %    Dec 1984, doi:10.1109/JOE.1984.1145645
end

%%
%!test
%! s = warning('off', 'matlab:get_permittivity:badFreq');
%! perm = get_permittivity ('air', 0)
%! perm = get_permittivity ({'air';'aluminum'}, 0)
%! temp = struct('name','arbitrary_real_imag', 'perm_real',rand, 'perm_imag',rand);
%! perm = get_permittivity (temp, 0)
%! perm = get_permittivity (temp.name, 0, temp)
%! perm = get_permittivity ({'air'; temp}, 0)
%! perm = get_permittivity ('snow')
%! perm = get_permittivity ('soil')
%! name = get_permittivity ('ice')
%! name = get_permittivity ('seawater')
%! warning(s);

%%
%!test
%! name = get_permittivity('list');
%! name(strstart('arbitrary',name)) = [];
%! name(cellfun(@isempty,name)) = [];
%! perm = cellfun(@get_permittivity, name);
%! %[perm, ind] = sort(perm);  name = name(ind);
%! cprintf(perm, '-Lr',name)
