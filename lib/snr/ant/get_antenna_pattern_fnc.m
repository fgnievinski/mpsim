function ant = get_antenna_pattern_fnc (ant, prod)
    prod_default = 'densemap';
    %prod_default = 'sphharm';
    %prod_default = 'profile';
    if (nargin < 2) || isempty(prod),  prod = prod_default;  end
    comp_eval = @(comp_type, elev, azim, polar) feval(...
        sprintf('snr_setup_ant_%s_eval', prod), ...
        elev, azim, ant.(comp_type).(polar).(prod));
    is_comp_available = @(comp_type) ~isfieldempty(ant, comp_type, 'rhcp') ...
                                  && ~isfieldempty(ant, comp_type, 'lhcp');
    if isfieldempty(ant, 'gain', 'eval') && is_comp_available('gain')
        ant.gain.eval = @(varargin) comp_eval('gain', varargin{:});
    end
    if isfieldempty(ant, 'phase', 'eval') && is_comp_available('phase')
        ant.phase.eval = @(varargin) comp_eval('phase', varargin{:});
    end
end
