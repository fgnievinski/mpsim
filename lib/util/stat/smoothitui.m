function varargout = smoothitui (...
smoothitwhich, interp_method, interp_extrapval, extra, ...
time, obs, std, dof, dt, Itime, varargin)
%SMOOTHITUI  Uncertainty-weighted running average, followed by interpolation.

    if (nargin < 1) || isempty(smoothitwhich),  smoothitwhich = @smoothitud;  end
    if (nargin < 2) || isempty(interp_method),  interp_method = 'linear';  end
    if (nargin < 3) || isempty(interp_extrapval),  interp_extrapval = [];  end
    if (nargin < 4),  extra = {};  end
    if (nargin < 10),  Itime = [];  end
    assert(isequal(smoothitwhich, @smoothitud)  || ...
           isequal(smoothitwhich, @smoothitudc) || ...
           isequal(smoothitwhich, @smoothitud2))

    argin = [extra {time, obs, std, dof, dt, Itime} varargin];
    nargout2 = nargout(smoothitwhich);
    if (nargout > nargout2)
        % user is requesting both interpolated and non-interpolated results:
        assert(iseven(nargout))
        nargouti = nargout/2;
        [varargoutI{1:nargouti}] = smoothitwhich (argin{:});
    else
        % user is requesting only interpolated results:
        nargouti = nargout;
        [varargoutI{1:nargouti}] = smoothitwhich (argin{:});
        varargoutI(nargouti+1:nargout2) = {[]};
    end

    F = @(in) interp1log(Itime, in, time, interp_method, interp_extrapval, @interp1nonemptynorscalar);
    varargouti = cellfun2(F, varargoutI);
    
    varargout = [varargouti, varargoutI];
    %varargout = [varargoutI, varargouti];  % WRONG! (then call smoothitwhich directly.)
end
