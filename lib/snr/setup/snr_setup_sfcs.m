function sfc = snr_setup_sfcs (sett_sfc, frequency, ref)
    % (support for PO surface patches)
    if ~iscell(sett_sfc),  sett_sfc = {sett_sfc};  end
    n = numel(sett_sfc);
    sfcs = cell(n,1);  % (sfc can't be a struct array because elements may be dissimilar.)
    for i=1:n
        sfcs{i} = snr_setup_sfc (sett_sfc{i}, frequency, ref);
    end
    if (n == 1),  sfc = sfcs{1};  else  sfc = sfcs;  end
end
