function [power, elev] = get_glo_power_min (freq_name, code_name)
    code_name = get_glo_synonym (code_name);
    all = get_glo_power_min_all ();
    
    idx_freq = ismembercc(all.freq_name, freq_name);
    idx_code = ismembercc(all.code_name, code_name);
    idx = idx_freq & idx_code;
    %myassert(sum(idx) == 1);
    %myassert(sum(idx) == 1);    
    if (sum(idx) ~= 1)
        error('snr:get_glo_power_min:badComb', ['Unknown combination of '...
            'frequency "%s", code "%s".'],...
            freq_name, code_name);
    end
    
    power_db = all.power_db(idx);
    power = decibel_power_inv(power_db);
    clear power_db
    [~, ~, factor] = get_glo_code_sizes (code_name);
    power = power / factor;
    elev = 5;  % in degrees
end

%%
function all = get_glo_power_min_all ()
    % From Edition 5.1 2008 ICD G1, G2 GLONASS  p.16
 
    % "The minimum received power is measured at the output of a 3 dBi
    % linearly polarized user receiving antenna, when the SV is above a 5-degree elevation
    % angle, and an atmosphere attenuation is 2dB"
    %   These values are in dBW, so they already include the
    % receiving antenna isotropic effective area. In other words, these
    % values are NOT power spatial density, in dB-W/m^2!
    
    % Despite the lack of ICD for the GLONASS P-code, Lennen (1989) found that the transmitted 
    % signal power is similar for C/A and P-codes
    % Lennen, Gary R, The USSR's Glonass P-code - Determination and initial results. Proceedings 
    % of ION GPS-89, Colorado Springs, CO, US, September 1989.
    
    all.freq_name = {...
        'R1'
        'R1'
        'R2'
        'R2'
    };

    all.code_name = {...
        'C/A'
        'P'
        'C/A'
        'P'
    };

    all.power_db = [...
        -161
        -161
        -167
        -167
    ];
end

