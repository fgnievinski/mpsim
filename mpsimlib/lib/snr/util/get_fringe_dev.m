% get fringe deviation w.r.t. background trend:
function fringe_dev = get_fringe_dev (phasor_direct, phasor_reflected, dev_which)
    if (nargin < 3) || isempty(dev_which),  dev_which = 'ins';  end
    switch lower(dev_which)
    case {'raw','ins','inst','instantaneous'}
        fringe_dev = get_fringe_dev_ins (phasor_direct, phasor_reflected);
    case {'avg','average','mean'}
        fringe_dev = get_fringe_dev_avg (phasor_direct, phasor_reflected);
    case {'sup','superior'}
        fringe_dev = get_fringe_dev_aux (phasor_direct, phasor_reflected, +1);
    case {'inf','inferior'}
        fringe_dev = get_fringe_dev_aux (phasor_direct, phasor_reflected, -1);
    case {'max','maximum'}
        fringe_dev_sup = get_fringe_dev (phasor_direct, phasor_reflected, 'sup');
        fringe_dev_inf = get_fringe_dev (phasor_direct, phasor_reflected, 'inf');
        fringe_dev = max(fringe_dev_sup, fringe_dev_inf);
    end        
end

%%
function fringe_dev = get_fringe_dev_ins (phasor_direct, phasor_reflected)
    phasor_composite = phasor_direct + phasor_reflected;
    [~, phasor_composite_trend] = get_fringe_aux (phasor_direct, phasor_reflected, 'trend');
    fringe_phasor = phasor_composite ./ phasor_composite_trend;
    fringe_pow = get_power(fringe_phasor);
    fringe_dev = decibel_power(fringe_pow);
end

%%
function fringe_dev = get_fringe_dev_aux (phasor_direct, phasor_reflected, sign)
    debugit = false;
    if debugit
        phasor_interf = phasor_reflected ./ phasor_direct;
        power_interf = get_power(phasor_interf);
        fringe_pow = (1 + sign * sqrt(power_interf)).^2 ./ (1 + power_interf);
    else
        fringe_vis = get_fringe_vis (phasor_direct, phasor_reflected);
        fringe_pow = (1 + sign * fringe_vis);
    end
    fringe_dev = decibel_power(fringe_pow);
    fringe_dev = sign*fringe_dev;
end

%%
function fringe_dev = get_fringe_dev_avg (phasor_direct, phasor_reflected)
%     phasor_interf = phasor_reflected ./ phasor_direct;
%     ampl_interf = abs(phasor_interf);
%     fringe_ampl = (1 + ampl_interf)./(1 - ampl_interf);
%     fringe_pow = fringe_ampl.^2;
%     fringe_dev = decibel_power(fringe_pow);
%    return;
    % DEBUG:
    fringe_dev_sup = get_fringe_dev (phasor_direct, phasor_reflected, 'sup');
    fringe_dev_inf = get_fringe_dev (phasor_direct, phasor_reflected, 'inf');
    fringe_dev = (fringe_dev_sup + fringe_dev_inf)./2;
end
