function varargout = get_gps_constant (freq_name, quantity)
    if (nargin == 0)
        freq_name = NaN;
        quantity = 'legacy';
        [varargout{1:nargout}] = get_gps_constant (freq_name, quantity);
        return;
    end
    if (nargin < 1) || isempty(freq_name),  freq_name = 'L2';  end
    if (nargin < 2) || isempty(quantity),  quantity = 'wavelength';  end
    
    %nargout, nargin  % DEBUG
    FREQUENCY0 = 10.23 * 1e6;  % Hz
    FACTOR_L1 = 154;
    FACTOR_L2 = 120;
    FACTOR_L5 = 115;
    FREQUENCY_L1 = FACTOR_L1 * FREQUENCY0;
    FREQUENCY_L2 = FACTOR_L2 * FREQUENCY0;
    FREQUENCY_L5 = FACTOR_L5 * FREQUENCY0;
    LIGHT_SPEED = get_standard_constant('speed of light in vaccum');  % m/s
    WAVELENGTH_L1 = LIGHT_SPEED / FREQUENCY_L1;
    WAVELENGTH_L2 = LIGHT_SPEED / FREQUENCY_L2;
    WAVELENGTH_L5 = LIGHT_SPEED / FREQUENCY_L5;

    if strcmp(quantity, 'legacy')
        varargout = {WAVELENGTH_L1, WAVELENGTH_L2, LIGHT_SPEED, FREQUENCY_L1, FREQUENCY_L2};
        return
    end
    
    switch upper(freq_name)
    case 'L1'
        WAVELENGTH = WAVELENGTH_L1;
        FREQUENCY  = FREQUENCY_L1;
    case 'L2'
        WAVELENGTH = WAVELENGTH_L2;
        FREQUENCY  = FREQUENCY_L2;
    case 'L5'
        WAVELENGTH = WAVELENGTH_L5;
        FREQUENCY  = FREQUENCY_L5;
    otherwise
        error('gps:get_gps_const:badFreqName', ...
          'Unknown freq_name "%s"; should be "L1", "L2", or "L5".', freq_name);
    end

%     %myeval = @(temp) eval([temp '_' upper(freq_name)]);
%     myeval = @(temp) evalin('caller', [temp '_' upper(freq_name)]);
%     try
%         WAVELENGTH = myeval('WAVELENGTH');
%         FREQUENCY  = myeval('FREQUENCY');
%     %catch err  % Octave-incompatible
%     catch %#ok<CTCH>
%         err = lasterror(); %#ok<LERR>
%         %disp(err.identifier)
%         error('gps:get_gps_const:badFreqName', ...
%           'Unknown freq_name "%s"; should be "L1", "L2", or "L5".', freq_name);
%     end
    
    switch lower(quantity)
    case 'wavelength'
        varargout = {WAVELENGTH, FREQUENCY};
    case 'frequency'
        varargout = {FREQUENCY, WAVELENGTH};
    otherwise
        error('gps:get_gps_const:badType', ...
          'Unknown quantity "%s"; should be "wavelength" or "frequency".', quantity);
    end
end

