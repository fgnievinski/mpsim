function [phasor_same, phasor_cross, phasor_perp, phasor_paral] = ...
get_reflection_coeff_circ (elev_incid, perm_bottom, perm_top, perm_middle, varargin)
    if (nargin < 3),  perm_top = [];  end
    if (nargin < 4),  perm_middle = [];  end
    assert(isempty(perm_middle))
    [phasor_perp, phasor_paral] = get_reflection_coeff_linear (...
        elev_incid, perm_bottom, perm_top);
%     phasor_paral = -phasor_paral;  % DEBUG
%     phasor_perp  = -phasor_perp;  % DEBUG
    [phasor_same, phasor_cross] = get_reflection_coeff_linear2circ (...
        phasor_perp, phasor_paral);
end
