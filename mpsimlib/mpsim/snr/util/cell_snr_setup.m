function setup = cell_snr_setup (sett, verbose, check_deprecated, renew_pre)
    check_deprecated_default = true;  % consistent with snr_setup.m.
    %check_deprecated_default = false;  % consistent with snr_resetup.m; use cell_snr_resetup.
    if (nargin < 2),  verbose = [];  end
    if (nargin < 3),  check_deprecated = [];  end
    if (nargin < 4),  renew_pre = [];  end
    if isempty(check_deprecated),  check_deprecated = check_deprecated_default;  end
    setup = snr_resetup (sett, [], verbose, check_deprecated, renew_pre);
end
