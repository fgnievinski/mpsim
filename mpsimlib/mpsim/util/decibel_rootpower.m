function dB = decibel_rootpower (rootpower)
    power = rootpower.^2;
    dB = decibel_power(power);  % = 20 .* log10(abs(amplitude));
end

