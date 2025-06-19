function [phasor, delay] = snr_fwd_delay (geom, setup)
    delay = geom.reflection.delay;
    phase = delay2phase (delay, setup.opt.wavelength);
    phasor = phasor_init(1, phase);
end

