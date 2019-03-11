function sfc = snr_setup_sfc_material_slab (...
frequency, material_bottom, material_top, material_middle, sfc)
    if (nargin < 3) || isempty(material_top),  material_top = 'air';  end
    if (nargin < 4),  material_middle = [];  end
    sfc.fnc_get_reflection_coeff = @get_reflection_coeff_slab;
    if isempty(material_bottom),  assert(~isempty(material_middle));  end
    sfc.permittivity_bottom = get_permittivity (material_bottom, frequency);
    sfc.permittivity_top    = get_permittivity (material_top, frequency);
    sfc.permittivity_middle = get_permittivity (material_middle, frequency);
    if isfieldempty(material_middle, 'thickness'),  material_middle.thickness = 0;  end
    if isfieldempty(material_middle, 'depth_min'),  material_middle.depth_min = 0;  end
    sfc.thickness = material_middle.thickness;
    sfc.depth_midpoint = sfc.thickness / 2;
    sfc.depth_interface = [0; sfc.thickness] + material_middle.depth_min;
    %sfc.depth_interface = [0; sfc.thickness];  % WRONG!
    if ~isscalar(sfc.permittivity_middle) ...
    || ~isscalar(sfc.thickness)
        error('snr:snr_setup_sfc_material_slab:badNum', ...
            'Bad number of elements in sfc.material_middle.')
    end
end
