function [result, snr_db, carrier_error, code_error] = snr_po_fwd (setup)
%SNR_PO_FWD: Physical Optics scattering with interface similar to snr_fwd.m

    %%
    if (nargin < 1),  setup = snr_setup();  end
    assert(~iscell(setup))  % TODO: cell_snr_po_fwd
    
    %% run simulation:
    [result2, snr_db, carrier_error, code_error] = snr_po (setup);

    %% reorganize results as vectors:
    result = struct();
    fn = fieldnames(result2);
    for i=1:numel(fn)
        result.(fn{i}) = [result2.(fn{i})]';
    end

    %% disable unreliable results:
    mistrunc = [result.info.mistrunc];
    for i=1:numel(fn)
        if isstruct(result.(fn{i})),  continue;  end
        result.(fn{i})(mistrunc) = NaN;
    end
    
    %% save satellite information:
    % (for convenience and compatibility with snr_fwd.m)
    result.sat = struct();
    result.sat.elev = [result.info.elev];
    result.sat.azim = [result.info.azim];
    
    %% keep a copy of the original results:
    result.orig = result2;
end
