function sfc = snr_setup_sfc_material_stacked (...
frequency, material_bottom, material_top, material, sfc)
    num_stacks = numel(material);
    sfc_all = repmat({struct()}, [num_stacks,1]);
    for i=1:num_stacks
        if isfieldempty(material(i), 'fnc_snr_setup_sfc_material')
            material(i).fnc_snr_setup_sfc_material = ...
                @snr_setup_sfc_material_interpolated;
        end
        if (i == 1)
            if isfieldempty(material(i), 'depth_min')
                material(i).depth_min = 0;
            end
            if (material(i).depth_min ~= 0)
                warning('snr:snr_setup_sfc_material_stacked:depthMin0', ...
                    'Minimum depth on first stack is not zero.');
            end
        else
            if isfieldempty(material(i), 'depth_min')
                material(i).depth_min = sfc_all{i-1}.depth_max;
            end
            if (material(i).depth_min ~= sfc_all{i-1}.depth_max)
                warning('snr:snr_setup_sfc_material_stacked:depthMinMax', ...
                    ['Stack #%d''s minimum depth is different than '...
                    'stack #%d''s maximum depth -- check for gaps.'], i, i-1);
            end
        end
        sfc_all{i} = material(i).fnc_snr_setup_sfc_material (...
            frequency, material_bottom, material_top, material(i), sfc);
        if ~isfield(sfc_all{i}, 'depth_max')
            sfc_all{i}.depth_max = sfc_all{i}.depth_interface(end);
        end
    end
    sfc.fnc_get_reflection_coeff = @get_reflection_coeff_layered;
    sfc.permittivity_bottom = get_permittivity (material_bottom, frequency);
    sfc.permittivity_top    = get_permittivity (material_top, frequency);
    sfc.permittivity_middle = [];
    sfc.thickness = [];
    sfc.depth_midpoint = [];
    sfc.depth_interface = [];
    for i=1:num_stacks
        sfc.permittivity_middle = vertcat(sfc.permittivity_middle, ...
            sfc_all{i}.permittivity_middle);
        sfc.thickness = vertcat(sfc.thickness, sfc_all{i}.thickness);
        sfc.depth_midpoint = vertcat(sfc.depth_midpoint, sfc_all{i}.depth_midpoint);
        sfc.depth_interface = vertcat(sfc.depth_interface, sfc_all{i}.depth_interface);
    end
end
