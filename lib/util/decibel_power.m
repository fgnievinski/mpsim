function dB = decibel_power (power, warnit)
    if (nargin < 2),  warnit = true;  end
    if warnit && ~isreal(power)
        warning('MATLAB:decibel_phasor:Complex', ...
          'Real-valued input expected.');
    end
    dB = 10 .* log10(power);
end

