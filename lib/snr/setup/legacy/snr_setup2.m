function setup_new = snr_setup2 (sett_old, sett_new, setup_old, verbose)
    if (nargin < 4),  verbose = [];  end
    if ~isfieldempty(setup_old, 'sett') ...
    && ~isequaln(setup_old.sett, sett_old)
        setup_old.sett = sett_old;
    end
    warning('snr:deprecated', ...
        ['Deprecated function "snr_setup2";'...
         '\nplease use "snr_resetup" instead.']);
    setup_new = snr_resetup (sett_new, setup_old, verbose, true);
end
