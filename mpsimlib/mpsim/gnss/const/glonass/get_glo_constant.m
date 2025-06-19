function varargout = get_glo_constant (freq_name, channel, quantity)
    if (nargin < 1) || isempty(freq_name),  freq_name = 'R2';  end
    if (nargin < 2) || isempty(channel) || isnan(channel),  channel = 0;  end
    if (nargin < 3) || isempty(quantity),  quantity = 'wavelength';  end
    
    %nargout, nargin  % DEBUG
    LIGHT_SPEED = get_standard_constant('speed of light in vaccum'); 
    FREQUENCY0 = 5e6;  % Hz
    FACTOR_R1 = 320.40;
    FACTOR_R2 = 249.20;
    SEPARATION_MULTIPLE_R1 = 562.5e3;
    SEPARATION_MULTIPLE_R2 = 437.5e3;
    
    switch upper(freq_name)
    case 'R1',  FACTOR = FACTOR_R1;  SEPARATION_MULTIPLE = SEPARATION_MULTIPLE_R1;
    case 'R2',  FACTOR = FACTOR_R2;  SEPARATION_MULTIPLE = SEPARATION_MULTIPLE_R2;
    otherwise,  error('snr:glo:get_glo_constant:badFreqName', ...
        'Unknown frequency name "%s".', freq_name);
    end

    FREQUENCY_CENTRAL = FACTOR * FREQUENCY0;
    SEPARATION_FACTOR = channel;
    FREQUENCY_SEPARATION = SEPARATION_FACTOR * SEPARATION_MULTIPLE;
    FREQUENCY = FREQUENCY_CENTRAL + FREQUENCY_SEPARATION;
    WAVELENGTH = LIGHT_SPEED / FREQUENCY;

    switch lower(quantity)
    case 'wavelength'
        varargout = {WAVELENGTH, FREQUENCY};
    case 'frequency'
        varargout = {FREQUENCY, WAVELENGTH};
    otherwise
        error('snr:glo:get_glo_const:badType', ...
          'Unknown quantity "%s"; should be "wavelength" or "frequency".', quantity);
    end
end

