function [setup, sett] = snr_resetup_check (sett, setup, verbose)
%SNR_RESETUP_CHECK:  Safer alternative to snr_resetup; recommended for use in test cases.

    if (nargin < 1),  sett = [];  end
    if (nargin < 2),  setup = [];  end
    if (nargin < 3),  verbose = [];  end
    check_deprecated = true;
    renew_pre = true;
    [setup, sett] = snr_resetup (sett, setup, verbose, check_deprecated, renew_pre);
end
