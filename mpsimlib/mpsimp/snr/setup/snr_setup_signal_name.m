function [gnss_name, freq_name, channel, block_name, code_name, subcode_name] = snr_setup_signal_name (...
gnss_name, freq_name, channel, block_name, code_name, subcode_name)
    if (nargin < 1),  gnss_name = [];  end
    if (nargin < 2),  freq_name = [];  end
    if (nargin < 3),  channel = [];  end
    if (nargin < 4),  block_name = [];  end
    if (nargin < 5),  code_name = [];  end
    if (nargin < 6),  subcode_name = [];  end
    
    % While Galileo one-letter identifier is always 'E' for both system and
    % frequency, in RINEX 3, Glonass has 'R' for system and 'G' for
    % frequency, while GPS has 'G' for system and 'L' for frequency (see
    % sections 3.5, "Satellite numbers", and 5.1, "Observation codes" of
    % the RINEX3 specs). To complicate matters, in the ANTEX file, 'G' is
    % always GPS, and 'R' is always GLONASS. Therefore, there is a
    % potential ambiguity in 'G' for frequency denomination.
    % 
    % To minimize confusion, for frequency we adopt 'R' for GLO (as in the
    % ANTEX file) and keep using the legacy 'L' for GPS; the 'G' is only
    % acceptable if gnss_name is also specified. For sytem designation,
    % instead of single letters, we give preference to the RINEX3
    % three-lettter time system identifier, which is the full 'GPS' on the
    % one hand and the abbreviated 'GLO' on the other hand (although we
    % will accept the full 'GLONASS' as synonymous for the latter).
    
    if strcmpi(gnss_name, 'GLONASS'),  gnss_name = 'GLO';  end
    if ~isempty(gnss_name) && none(strcmpi(gnss_name, {'GPS','GLO'}))
        error('snr:snr_setup_opt:unkGnss', 'Unknown GNSS name "%s".', gnss_name);
    end
    if ~isempty(freq_name) && ~any(strcmpi(freq_name, {'L1','L2','L5','R1','R2','G1','G2','G5'}))
        error('snr:snr_setup_opt:unkFreq', 'Unknown frequency name "%s".', freq_name);
    end

    if isempty(gnss_name) ...
    && isempty(freq_name)
        gnss_name = 'GPS';
        freq_name = 'L2';
    elseif isempty(freq_name) % && ~isempty(gnss_name)
        switch upper(gnss_name)
        case 'GPS',  freq_name = 'L2';
        case 'GLO',  freq_name = 'R2';
        end
    elseif isempty(gnss_name) % && ~isempty(freq_name)
        switch upper(freq_name(1))
        case 'L',  gnss_name = 'GPS';
        case 'R',  gnss_name = 'GLO';
        case 'G'
            error('snr:snr_setup_opt:ambFreq', ...
                'Ambiguous frequency name "%s" for empty GNSS name.', ...
                freq_name);
        end
    end
    
    if ~isempty(channel) && ~strcmpi(gnss_name, 'GLO')
        warning('snr:snr_setup_opt:channelNotGlo', ...
            'Channel only applies to GLONASS; ignoring non-empty sett.opt.channel.');
        channel = [];
    end
    
    %% Synonyms:
    if strncmpi(freq_name, 'G', 1)
        switch upper(gnss_name)
        case 'GPS',  freq_name(1) = 'L';
        case 'GLO',  freq_name(1) = 'R';
        otherwise  % leave as it was input.
        end
    end
    if strcmpi(gnss_name, 'GLO') && strncmpi(freq_name, 'L', 1)
        warning('snr:snr_setup_opt:inconsitent', ...
            ['Inconsistent GNSS name "%s" and frequency name "%s"; '...
             'the former is taking precedence.'], ...
            gnss_name, freq_name);
        freq_name(1) = 'R';
    end
    if strcmpi(gnss_name, 'GPS') && strncmpi(freq_name, 'R', 1)
        warning('snr:snr_setup_opt:inconsitent', ...
            ['Inconsistent GNSS name "%s" and frequency name "%s"; '...
             'the former is taking precedence.'], ...
            gnss_name, freq_name);
        freq_name(1) = 'L';
    end
    
    if strcmpi(code_name, 'CA')
    %&& any(strcmpi(freq_name, {'L1','L2','L5','R1','R2'}))
        code_name = 'C/A';
    end
%     
%     if strcmpi(code_name, 'C') && strcmpi(freq_name, 'L1')
%         code_name = 'C/A';
%     end
    
    if any(strcmpi(code_name, {'C','X','S'})) && strcmpi(freq_name, 'L2')
        code_name = 'L2C';
    end
    
    if strcmpi(gnss_name, 'GPS') ...
    && any(strcmpi(code_name, {'P','Y','W'}))
        code_name = 'P(Y)';  % TODO: distinguish their losses.
    end
    
    if strcmpi(gnss_name, 'GLO') ...
    && strcmpi(code_name, 'P(Y)')
        code_name = 'P';
    end
    
    if strcmpi(freq_name, 'L5') ...
    && any(strcmpi(code_name, {'I','Q'}))
        [code_name, subcode_name] = deal('L5', code_name(1));  % legacy interface.
    end    
    
    %% Default code names:
    if isempty(code_name)
        switch upper(freq_name)
        case {'L1','R1'},  code_name = 'C/A';
        case 'L2',  code_name = 'L2C';
        %case 'L2',  code_name = ''P(Y);
        %case 'R2',  code_name = 'P';
        case 'R2',  code_name = 'C/A';
        case 'L5',  code_name = 'L5';
        otherwise,  error('snr:snr_setup_opt:emptyCodeName', 'Empty code name.');
        end
    end
    if isempty(subcode_name)
        switch upper(freq_name)
        case {'L1','R1','R2'}  % leave it empty.
        case 'L2'
            if strcmpi(code_name, 'L2C'),  subcode_name = 'CL';  end
        case 'L5',  subcode_name = 'Q';
        end
    end
    if strcmpi(gnss_name, 'GPS')
        [code_name, subcode_name] = get_gps_synonym (code_name, subcode_name, freq_name);
    end
    if isempty(block_name)
        switch upper(freq_name)
        case 'L1',  block_name = 'IIR';
        case {'R1','R2'}  %  leave it empty.
        case 'L2',  block_name = 'IIR';
          if strcmpi(code_name, 'L2C'),  block_name = 'IIR-M';  end
        case 'L5',  block_name = 'IIF';
        end
    end
end

