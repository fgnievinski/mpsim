function sfc = snr_setup_sfc_material_halfspaces (...
frequency, material_bottom, material_top, material_middle, sfc)
%frequency, material_top, material_bottom, material_middle, sfc)  % WRONG! DEBUG
    if (nargin < 3) || isempty(material_top),  material_top = 'air';  end
    if (nargin < 4),  material_middle = [];  end
    assert(isempty(material_middle))
    assert(~isempty(material_bottom))
    sfc.fnc_get_reflection_coeff = @get_reflection_coeff_homogeneous;
    sfc.permittivity_bottom = get_permittivity (material_bottom, frequency);
    sfc.permittivity_top = get_permittivity (material_top, frequency);
    sfc.permittivity_middle = [];
    sfc.permittivity = sfc.permittivity_bottom;  % synonymous
end
