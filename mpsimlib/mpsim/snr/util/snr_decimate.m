function [snrd, elevd, snr_decimate_fnc] = snr_decimate (snr, elev, ...
indep_spacing, indep_type, strictly_regularly_spaced, discard_nans, elev_lim, varargin)
    if (nargin < 3),  indep_spacing = [];  end
    if (nargin < 4),  indep_type = [];  end
    if (nargin < 5) || isempty(strictly_regularly_spaced),  strictly_regularly_spaced = false;  end
    if (nargin < 6) || isempty(discard_nans),  discard_nans = false;  end    
    if (nargin < 7),  elev_lim = [];  end    
    if strictly_regularly_spaced && discard_nans
        warning('snr:decimate:NaNs', ...
            'Ignoring strictly_regularly_spaced = true when ignore_nans = true.');
        strictly_regularly_spaced = false;
    end
    
    [snr_decimate_fnc, elevi] = snr_decimate_aux (elev, indep_spacing, indep_type, elev_lim, varargin{:});
    
    if ~iscell(snr)
        snrd = snr_decimate_fnc(snr);
        if discard_nans
            idx = ~isnan(snrd);
            snrd = getel(snrd, idx);
            snr_decimate_fnc = @(in) getel(snr_decimate_fnc(in), idx);
        end
    else
        snrd = cellfun2(snr_decimate_fnc, snr);
        if discard_nans
            snrd1 = snrd{1};
            idx = ~isnan(snrd1);
            snrd = cellfun2(@(in) getel(in, idx), snrd);
            snr_decimate_fnc = @(in) getel(snr_decimate_fnc(in), idx);
        end
    end

    if strictly_regularly_spaced
        elevd = elevi;
        assert(~discard_nans)
    else
        elevd = snr_decimate_fnc(elev);
    end
end

%%
function [snr_decimate_fnc, elevi] = snr_decimate_aux (elev, indep_spacing, indep_type, elev_lim, varargin)
    [elevi, indepi, elev2indep] = snr_decimate_indep (indep_spacing, indep_type, elev_lim, varargin{:});
    indep = elev2indep(elev);
    [indib, india] = snr_decimate_ind (indep, indepi);
    snr_decimate_fnc = @(x) setel(NaN(size(indepi)), indib, x(india));
end

%%
function [indib, india] = snr_decimate_ind (var, vari)
    [varu, ind] = unique(var);
    if isscalar(varu)
        india = [];
        indib = [];
        return
    end
    
    indi = naninterp1(varu, ind, vari, 'nearest', NaN);
    %indil= naninterp1(varu, ind, vari, 'linear', NaN);
    % we do nearest neighbor interpolation to keep observations unaltered 
    % and also because azimuth would require special treatment (azimuth_interp.m)

    % avoid duplicating observations:
    % while also avoiding returning an observation which is too distant
    %[india, indib] = unique(indi);
    %idx = isnan(india);  india(idx) = [];  indib(idx) = [];
    [india1, indib1] = unique(indi, 'first');
    [india2, indib2] = unique(indi, 'last');
    idx = isnan(india1);
    idx = idx | (indib1~=indib2);
    india1(idx) = [];  indib1(idx) = [];
    india2(idx) = [];  indib2(idx) = [];
    assert(isequal(india1, india2));
    assert(isequal(indib1, indib2));
    india = india1;
    indib = indib1;
end

%%
