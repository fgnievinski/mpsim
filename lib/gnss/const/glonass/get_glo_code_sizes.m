function [effective_chip_width_in_meters, code_length_in_meters, multiplex_factor] = get_glo_code_sizes (code_name)
    if (nargin < 1),  code_name = 'C/A';  end
    code_name = get_glo_synonym (code_name);
    c = get_standard_constant('speed of light in vaccum');
    multiplex_factor = 1;
    switch upper(code_name)
    case 'C/A'
        % As per GLONASS ICD:
        % "PR ranging code [has] ... a period 1 millisecond":
        code_length_in_seconds = 1e-3;
        % "... and bit rate of 511 kilobits per second":
        chipping_rate_in_chipspersec = 511e3;
    case 'P'
        % As per Boon et al. (1998), "GPS+GLONASS RTK: Making the Choice Between Civilian and Military L2 GLONASS"
        % <http://www.ion.org/publications/abstract.cfm?articleID=8190>
        % <https://www.researchgate.net/publication/267400086>
        % 
        % Also Mohinder S. Grewal, Angus P. Andrews, Chris G. Bartone (2013) "Global Navigation Satellite Systems, Inertial Navigation, and Integration", p.142 <https://books.google.com.br/books?id=fzZaxpoFekAC&lpg=PA78&dq=glonass%20precise%20code%20length%201%20second&pg=PA78#v=onepage&q=glonass%20precise%20code%20length%201%20second&f=false>
        chipping_rate_in_chipspersec = 5.11e6;
        % As per Grewal et al. (ibid):
        code_length_in_seconds = 1e-3;
    otherwise
        error('snr:get_glo_code_sizes:unkCode', 'Unknown code "%s".', code_name);
    end
    % Calculate dependent variables:
    code_length_in_meters = code_length_in_seconds * c;
    code_length_in_chips = chipping_rate_in_chipspersec * code_length_in_seconds;
    effective_chip_width_in_meters = code_length_in_meters / code_length_in_chips / multiplex_factor;
end

