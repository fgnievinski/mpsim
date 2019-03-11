function sfc = snr_setup_sfc_material_parametric (...
frequency, material_bottom, material_top, material, sfc)
    if isfieldempty(material, 'depth_min')
        material.depth_min = 0;
    end
    if ~isfieldempty(material, 'thickness')
        warning('snr:snr_setup_sfc_material_parametric:badThickness', ...
            ['Ignoring non-empty thickness field input; '...
             'generating it from the depth fields.']);
    end
    material.depth_interface = (material.depth_min:material.depth_step:material.depth_max)';
    material.thickness = diff(material.depth_interface);
    material.depth_midpoint = material.depth_interface(1:end-1) + material.thickness ./ 2;

    material.property_eval = material.fnc_property(...
        material.depth_midpoint, material.property_param);
    material.(material.property_name) = material.property_eval;
    
    sfc = snr_setup_sfc_material_layered (...
        frequency, material_bottom, material_top, material, sfc);
      
    sfc.property_eval = material.property_eval;
    sfc.(material.property_name) = material.property_eval;
end
