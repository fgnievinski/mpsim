function varargout = snr_setup_ant_pattern (varargin)
    persistent nargin_old nargout_old varargin_old varargout_old
    %disp(varargin_old)  % DEBUG
    %disp(varargin)  % DEBUG
    if isequal(nargin, nargin_old) && isequal(nargout, nargout_old) ...
    && isequaln(varargin, varargin_old)
        varargout = varargout_old;
        return;
    end
    [varargout{1:nargout}] = snr_setup_ant_pattern_aux (varargin{:});
    nargin_old = nargin;
    nargout_old = nargout;
    varargin_old = varargin;
    varargout_old = varargout;
end

%%
function [gain, phase] = snr_setup_ant_pattern_aux (...
model, radome, freq_name, ...
sph_harm_degree, load_redundant, switch_left_right, load_extended)
    if (nargin < 4),  sph_harm_degree = [];  end
    if (nargin < 5),  load_redundant = [];  end
    if (nargin < 6),  switch_left_right = [];  end
    if (nargin < 7),  load_extended = [];  end
    
    %if strcmpi(model, 'isotropic')  % WRONG!
    if strstarti('isotropic', model)
        [gain, phase] = snr_setup_ant_pattern_iso (model, radome);
        return;
    end
    
    temp = {model, radome, freq_name, sph_harm_degree, load_redundant, switch_left_right, load_extended};
    gain  = snr_setup_ant_comp ('gain',  temp{:});
    phase = snr_setup_ant_comp ('phase', temp{:});
end

%%
function [gain, phase] = snr_setup_ant_pattern_iso (model, radome)
    if ~isempty(radome) && ~strcmpi(radome, 'none')
        warning('snr:snr_setup_ant_gain:iso', ...
            'Ignoring radome "%s" for antenna type "%s".', ...
            radome, model);
    end
    gain = struct();
    phase = struct();
    qualifier = model(numel('isotropic')+2:end);
    switch strtrim(lower(char(qualifier)))
    case ''
        gain.eval = @(elev, azim, polar) ones(size(elev));
        phase.eval = [];
    case {'rhcp','lhcp'}
        gain.eval = @(elev, azim, polar) repmat(cast(strcmpi(polar, qualifier), class(elev)), size(elev));
        phase.eval = [];
    case {'horz','horiz','horizontal'}
        % phasor_horz = (phasor_rhcp + phasor_lhcp) ./ sqrt(2);
        factor = 1/sqrt(2);
        gain.eval = @(elev, azim, polar) repmat(factor, size(elev));
        phase.eval = @(elev, azim, polar) zeros(size(elev));
        %phase.eval = [];  % WRONG!  would get replaced with defaults.
    case {'vert','vertical'}
        % phasor_vert = (phasor_rhcp - phasor_lhcp) .* 1i* ./ sqrt(2);
        %factor = 1/sqrt(2);
        factor = 1i/sqrt(2);
        sign = @(polar) double(strcmpi(polar, 'rhcp'));  % sign('rhcp') == +1, sign('lhcp') == -1.
        phasor_eval = @(elev, azim, polar) repmat(sign(polar)*factor, size(elev));
        gain.eval  = @(varargin) abs(phasor_eval(varargin{:}));
        phase.eval = @(varargin) get_phase(phasor_eval(varargin{:}));
    otherwise
        error('snr:snr_setup_ant_gain:isoUnk', ...
            'Unknown antenna isotropic qualifier "%s".', ...
            qualifier);
    end
end
