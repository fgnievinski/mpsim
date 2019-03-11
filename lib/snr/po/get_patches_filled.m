function z_list = get_patches_filled (first_arg, id, num_patches, num_cols)
    assert(isvector(id))
    if (nargin < 3) || isempty(num_patches),  num_patches = numel(unique(id));  end
    if (nargin < 4) || isempty(num_cols),  num_cols = 1;  end
    if isa(first_arg, 'function_handle')  % e.g., height
        z_fnc = first_arg;
        z_list = get_patches_filled_aux (z_fnc, id, num_patches, num_cols);
        return;
    end
    if isscalar(first_arg)
        z_list = repmat(first_arg, [numel(id) num_cols]);
        return;
    end
    if (numel(first_arg) ~= num_patches)
        error('snr:po:patch:filled:badSize', ...
            'Non-scalar input needs to match number of patches.');
    end
    z_fnc = @(i,idx) first_arg(i);  % e.g., roughness
    z_list = get_patches_filled_aux (z_fnc, id, num_patches);
end

function z_list = get_patches_filled_aux (z_fnc, id, num_patches, num_cols)
    z_list = NaN([numel(id) num_cols]);
    for i=1:num_patches
        idx = (id == i);
        temp = z_fnc(i,idx);
        % accomodate for is_z_uniform:
        if (size(temp,1) == 1),  temp = repmat(temp, [sum(idx) 1]);  end
        z_list(idx, :) = temp;
    end
end

