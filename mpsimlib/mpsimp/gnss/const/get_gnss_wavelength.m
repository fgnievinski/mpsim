function wavelength = get_gnss_wavelength (input, channel)
    if (nargin < 1),  input = [];  end
    if (nargin < 2),  channel = [];  end
    quantity = 'wavelength';
    %if isnumeric(input),  wavelength = input;  return;  end  % WRONG! too soon
    if isempty(input) || ischar(input)
        freq_name = input;
        gnss_name = get_gnss_freq2gnss (freq_name);      
        wavelength = get_gnss_constant (gnss_name, freq_name, channel, quantity);
        return;
    end
    if isnumeric(input),  wavelength = input;  return;  end
    % else: let it error;
end

