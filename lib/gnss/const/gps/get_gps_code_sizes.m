function [effective_chip_width_in_meters, code_length_in_meters, multiplex_factor] = get_gps_code_sizes (code_name, subcode_name, freq_name)
    if (nargin < 2),  subcode_name = '';  end
    if (nargin < 3),  freq_name = '';  end
    [code_name, subcode_name] = get_gps_synonym (code_name, subcode_name, freq_name);
    multiplex_factor = 1;
    switch upper(code_name)
    case 'C/A'
        code_length_in_chips = 1023;
        code_length_in_seconds = 1e-3;
    case 'P(Y)'
        code_length_in_days = 7;
        code_length_in_seconds = 3600*24*code_length_in_days;
        chipping_rate_in_chipspersec = 10.23e6;
        code_length_in_chips = chipping_rate_in_chipspersec * code_length_in_seconds;
        % the ICD is unclear about code_length_in_chips (it mentions values 15345000, 15345037).
    %case 'L1C'  % TBD (future signal).
    case 'L2C'
        multiplex_factor = 2;
        % "The modulated CM code and the unmodulated CL code 
        % are combined in a chip by chip multiplexer."
        % <http://navcen.uscg.gov/pdf/gps/TheNewL2CivilSignal.pdf>
        %if isempty(subcode_name), end
        switch upper(subcode_name)
        case {'CM','S'}
            code_length_in_chips = 10230;
            code_length_in_seconds = 20e-3;
            % CM – the L2C moderate length code contains 
            % 10,230 chips, repeats every 20 milliseconds, and 
            % is modulated with message data.
        case {'CL','L'}
            code_length_in_chips = 767250;
            code_length_in_seconds = 1.5;
            % CL – the L2C long code contains 767,250 chips, 
            % repeats every 1.5 second, is synchronized with 
            % the 1.5 second Z-count, and has no data modulation        
        case ''
            % L2C-CM and L2C-CL have the same chip width:
            effective_chip_width_in_meters1 = get_gps_code_sizes ('L2C', 'CL');
            effective_chip_width_in_meters2 = get_gps_code_sizes ('L2C', 'CM');
            assert(effective_chip_width_in_meters1 == effective_chip_width_in_meters2)
            effective_chip_width_in_meters = effective_chip_width_in_meters1;
            % this case is ambiguous with regard to code length:
            code_length_in_meters = NaN;
            multiplex_factor = NaN;
            return;
        otherwise
            error('snr:get_gps_code_sizes:unkCode', 'Unknown subcode "%s".', subcode_name);
        end
    case 'L5'
        if isempty(subcode_name) || ismember(subcode_name, {'I','Q','X'})
            % <http://www.gps.gov/technical/icwg/IS-GPS-705B.pdf>, sec. 3.2.1.1
            code_length_in_seconds = 1e-3;
            chipping_rate_in_chipspersec = 10.23e6;
            code_length_in_chips = chipping_rate_in_chipspersec * code_length_in_seconds;
            %multiplex_factor = 2;  % WRONG!
        else
            error('snr:get_gps_code_sizes:unkCode', 'Unknown subcode "%s".', subcode_name);
        end
    otherwise
        error('snr:get_gps_code_sizes:unkCode', 'Unknown code "%s".', code_name);
    end
    c = get_standard_constant('speed of light in vaccum');
    code_length_in_meters = code_length_in_seconds * c;
    effective_chip_width_in_meters = code_length_in_meters / code_length_in_chips / multiplex_factor;
end

%!test
%! c = get_standard_constant('c');
%! 
%! chip_width_in_meters = get_gps_code_sizes ('C/A');
%! chipping_rate_in_chipspersec = c / chip_width_in_meters;
%! chipping_rate_in_chipspersec2 = 1023e3;
%! %chipping_rate_in_chipspersec2 - chipping_rate_in_chipspersec  % DEBUG
%! myassert(chipping_rate_in_chipspersec, chipping_rate_in_chipspersec2)
%! 
%! effective_chip_width_in_meters = get_gps_code_sizes ('L2C');
%! effective_chipping_rate_in_chipspersec = c / effective_chip_width_in_meters;
%! chipping_rate_in_chipspersec2 = 511.5e3;
%! effective_chipping_rate_in_chipspersec2 = 2 * chipping_rate_in_chipspersec2;
%! %effective_chipping_rate_in_chipspersec2 - effective_chipping_rate_in_chipspersec  % DEBUG
%! myassert(effective_chipping_rate_in_chipspersec, effective_chipping_rate_in_chipspersec2)
%! 
%! chip_width_in_meters = get_gps_code_sizes ('P(Y)');
%! chipping_rate_in_chipspersec = c / chip_width_in_meters;
%! chipping_rate_in_chipspersec2 = 10.23e6;
%! %chipping_rate_in_chipspersec2 - chipping_rate_in_chipspersec  % DEBUG
%! myassert(chipping_rate_in_chipspersec, chipping_rate_in_chipspersec2)
%! 
%! [chip_width_in_meters, code_length_in_meters] = get_gps_code_sizes ('P(Y)');
%! code_length_in_chips = code_length_in_meters / chip_width_in_meters;
%! code_length_in_chips2 = 6.187e12;  % from http://www.novatel.com/assets/Documents/NovAtelPosterGPSworld.pdf
%! tol = 0.0005e12;
%! %code_length_in_chips2 - code_length_in_chips, tol  % DEBUG
%! myassert(code_length_in_chips, code_length_in_chips2, -abs(tol))


