function frequency = get_gnss_frequency (input, channel)
    if (nargin < 1),  input = [];  end
    if (nargin < 2),  channel = [];  end
    quantity = 'frequency';
    %if isnumeric(input),  frequency = input;  return;  end  % WRONG! too soon
    if isempty(input) || ischar(input)
        freq_name = input;
        gnss_name = get_gnss_freq2gnss (freq_name);      
        frequency = get_gnss_constant (gnss_name, freq_name, channel, quantity);
        return;
    end
    if isnumeric(input),  frequency = input;  return;  end
end

