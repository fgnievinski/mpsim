function [gnss_name, freq_name] = get_gnss_freq2gnss (freq_name)
    freq_name_default = 'L2';
    if (nargin < 1) || isempty(freq_name),  freq_name = freq_name_default;  end
    switch upper(freq_name(1))
    case 'L',  gnss_name = 'GPS';
    case 'R',  gnss_name = 'GLO';
    end    
end

