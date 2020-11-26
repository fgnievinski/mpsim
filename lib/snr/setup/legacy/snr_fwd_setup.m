% (this is a legacy interface, kept for backwards compatibility;
%  we recommend using instead the modern version: snr_setup.)
function varargout = snr_fwd_setup (sett, ant)
    if (nargin < 2),  ant = [];  end
    if ~isempty(ant)
        warning('snr:snr_fwd_setup:badArg', ...
            'Ignoring second argument -- syntax deprecated.');
    end
    [varargout{1:nargout('snr_fwd_setup_aux')}] = snr_fwd_setup_aux (sett);
    if (nargout == 1),  varargout = {varargout};  end  % that's why we have an aux. fnc.
end

function [sat, sfc, ant, ref, opt, bias] = snr_fwd_setup_aux (sett)
    setup = snr_setup (sett);
    sat = setup.sat;
    sfc = setup.sfc;
    ant = setup.ant;
    ref = setup.ref;
    opt = setup.opt;
    bias = setup.bias;
end

