function dB = decibel_phasor (phasor, warnit)
    if (nargin < 2),  warnit = true;  end
    if warnit && isreal(phasor)
        warning('MATLAB:decibel_phasor:nonComplex', ...
          'Complex-valued input expected.');
    end
    dB = decibel_power(get_power(phasor));
end

