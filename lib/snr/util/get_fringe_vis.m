% get fringe visibility.
function fringe_vis = get_fringe_vis (phasor_direct, phasor_reflected, method)
    if (nargin < 3) || isempty(method),  method = 1;  end
    % these two methods are equivalent.
    switch method
    case 1
        phasor_interf = phasor_reflected ./ phasor_direct;
        power_interf = get_power(phasor_interf);
        fringe_vis = 2*sqrt(power_interf)./(1+power_interf);
    case 2
        [~, phasor_max] = get_fringe_aux (phasor_direct, phasor_reflected, 'max');
        [~, phasor_min] = get_fringe_aux (phasor_direct, phasor_reflected, 'min');
        power_max = get_power(phasor_max);
        power_min = get_power(phasor_min);
        power_midrange = (power_max - power_min)./2;
        power_average  = (power_max + power_min)./2;
        fringe_vis = power_midrange ./ power_average;
    end
end
