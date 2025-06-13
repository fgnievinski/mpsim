function sfc = snr_setup_sfc_material_layered (...
frequency, material_bottom, material_top, material_middle, sfc)
    if (nargin < 3) || isempty(material_top),  material_top = 'air';  end
    if (nargin < 4),  material_middle = [];  end
    sfc.fnc_get_reflection_coeff = @get_reflection_coeff_layered;
    if isempty(material_bottom),  assert(~isempty(material_middle));  end
    sfc.permittivity_bottom = get_permittivity (material_bottom, frequency);
    sfc.permittivity_top    = get_permittivity (material_top, frequency);
    sfc.permittivity_middle = get_permittivity (material_middle, frequency);
    if isfieldempty(material_middle, 'thickness'),  material_middle.thickness = 0;  end
    sfc.thickness = material_middle.thickness(:);
    if all(isfield(material_middle, {'depth_midpoint','depth_interface'}))
        sfc.depth_midpoint  = material_middle.depth_midpoint;
        sfc.depth_interface = material_middle.depth_interface;
        assert(isequal(diff(sfc.depth_interface), sfc.thickness))
        assert(numel(sfc.depth_midpoint) == numel(sfc.thickness))
    else
        if isfield(material_middle, 'depth_min') && ~isempty(material_middle.depth_min)
            depth_min = material_middle.depth_min;
        else
            depth_min = 0;
        end
        sfc.depth_interface = depth_min + [0; cumsum(sfc.thickness)];
        sfc.depth_midpoint  = sfc.depth_interface(1:end-1) + sfc.thickness ./ 2;
    end
    m = numel(sfc.permittivity_middle);
    n = numel(sfc.thickness);
    if (m ~= n)
        if (m == 1)
            sfc.permittivity_middle = repmat(sfc.permittivity_middle, [n,1]);
        elseif (n == 1)
            sfc.thickness = repmat(sfc.thickness, [m,1]);
        else
        	error('snr:snr_setup_sfc_material_layered:badNum', ...
                'Bad number of elements in sfc.material_middle.')
        end
    end
end
