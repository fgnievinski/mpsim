function phase = delay2phase (delay, wavelength)
    %phase = delay .* (2*pi / wavelength);
    phase = delay .* (360 / wavelength);  % our standard convention for phase units.
end

