function [code_name, subcode_name] = get_glo_synonym (code_name, subcode_name)
    % see also: get_gps_synonym.m
    % we accept both version 2 and 3 RINEX designations.
    switch upper(code_name)
    case {'C/A','C'}
        code_name = 'C/A';
        subcode_name = '';
    case {'P(Y)','P','W','Y'}
        %code_name = 'P(Y)';  % WRONG!
        code_name = 'P';
        subcode_name = '';
    otherwise
        error('snr:get_glo_synonym:unkCode', 'Unknown code "%s".', code_name);
    end
end
