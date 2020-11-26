function [power, elev] = get_gps_power_min (freq_name, block_name, code_name, subcode_name)
    [code_name, subcode_name] = get_gps_synonym (code_name, subcode_name, freq_name);
    all = get_gps_power_min_all ();
    
    idx_freq    = ismembercc(all.freq_name,    freq_name);
    idx_block   = ismembercc(all.block_name,   block_name);
    idx_code    = ismembercc(all.code_name,    code_name);
    idx_subcode = ismembercc(all.subcode_name, subcode_name);    
    idx = idx_freq & idx_block & idx_code & idx_subcode;
    %myassert(sum(idx) == 1);
    %myassert(sum(idx) == 1);    
    if (sum(idx) ~= 1)
        error('snr:get_gps_power_min:badComb', ...
            'Unknown combination of frequency "%s", block "%s", code "%s", subcode "%s".',...
            freq_name, block_name, code_name, subcode_name);
    end
    
    power_db = all.power_db(idx);    
    power = decibel_power_inv(power_db);
    clear power_db
    [~, ~, factor] = get_gps_code_sizes (code_name, subcode_name, freq_name);
    power = power / factor;
    % "The L2C signal structure divides the transmitted civil 
    % signal into two equal-power components (...)
    % The two L2C signal components (channels) 
    % have half the total power, or -3 dB each..."
    % <http://navcen.uscg.gov/pdf/gps/TheNewL2CivilSignal.pdf>
    elev = 5;  % in degrees
end

%%
function all = get_gps_power_min_all ()
    % From IS-GPS-200F, 21 Sep 2011, Table 3-Va, p.18
    % <www.gps.gov/technical/icwg/IS-GPS-200F.pdf>:
    % and
    % From IS-GPS-705B, 21 Sep 2011, Table 3-III, p.10
    % <www.gps.gov/technical/icwg/IS-GPS-705B.pdf>:
    % Freq, Block, Code, Power (dBW re 1 W)
    %   L1  II/IIA/IIR  P(Y)    -161.5
    %   L1  II/IIA/IIR  C/A     -158.5
    %   L2  II/IIA/IIR  P(Y)    -164.5
    %   L1  IIR-M/IIF   P(Y)    -161.5
    %   L1  IIR-M/IIF   C/A     -158.5
    %   L2  IIR-M/IIF   P(Y)    -161.5
    %   L2  IIR-M/IIF   L2C     -160.0
    %   L2  IIR-M/IIF   C/A     -160.0
    %   L5  IIF         I       -157.9
    %   L5  IIF         Q       -157.9
    %   L5  III         I       -157.0
    %   L5  III         Q       -157.0
    % "The minimum received power is measured at the output of a 3 dBi
    % linearly polarized user receiving antenna (located near ground) at
    % worst normal orientation, when the SV is above a 5-degree elevation
    % angle."
    %   These values are in dBW, so they already include the
    % receiving antenna isotropic effective area. In other words, these
    % values are NOT power spatial density, in dB-W/m^2!
    all.freq_name = {...
        'L1'
        'L1'
        'L2'
        'L1'
        'L1'
        'L2'
        'L2'
        'L2'
        'L5'
        'L5'
    };
    all.block_name = {...
        {'II', 'IIA', 'IIR'}
        {'II', 'IIA', 'IIR'}
        {'II', 'IIA', 'IIR'}
        {'IIR-M', 'IIF'}
        {'IIR-M', 'IIF'}
        {'IIR-M', 'IIF'}
        {'IIR-M', 'IIF'}
        {'IIR-M', 'IIF'}
        {'IIF'}
        {'III'}
    };
    all.code_name = {...
        'P(Y)'
        'C/A'
        'P(Y)'
        'P(Y)'
        'C/A'
        'P(Y)'
        'L2C'
        'C/A'
        'L5'
        'L5'
    };
    all.subcode_name = {...
        {''}
        {''}
        {''}
        {''}
        {''}
        {''}
        {'CM','CL'}
        {''}
        {'I','Q','X'}
        {'I','Q','X'}
    };
    all.power_db = [...
        -161.5
        -158.5
        -164.5
        -161.5
        -158.5
        -161.5
        -160.0
        -160.0
        -157.9
        -157.0
    ];
end

