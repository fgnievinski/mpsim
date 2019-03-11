function [code_name, subcode_name] = get_gps_synonym (code_name, subcode_name, freq_name)
    if (nargin < 2),  subcode_name = '';  end
    if (nargin < 3),  freq_name = '';  end
    if any(strcmpi(code_name, {'S','L','X'}))
        % short, long, and mixed modernized code designations are ambiguous.
        assert(~isempty(freq_name))
        code_name = [freq_name code_name];
    end
    % we accept both version 2 and 3 RINEX designations.
    switch upper(code_name)
    case {'C/A','C'}
        code_name = 'C/A';
        subcode_name = '';
    case {'P(Y)','P','W','Y','D'}
        code_name = 'P(Y)';
        subcode_name = '';
    case {'L1C','L1S','L1L','L1X'}
        if ~strcmpi(code_name, 'L1C')
            subcode_name = code_name(3);
        end
        code_name = 'L1C';
    case {'L2C','L2S','L2L','L2X'}
        if ~strcmpi(code_name, 'L2C')
            subcode_name = code_name(3);
        end
        code_name = 'L2C';
    case {'L5','L5I','L5Q','L5X'}
        if ~strcmpi(code_name, 'L5')
            subcode_name = code_name(3);
        end
        code_name = 'L5';
    otherwise
        error('snr:get_gps_synonym:unkCode', 'Unknown code "%s".', code_name);
    end
end
