function [id, num_patches] = get_patches_id (lim, x_list, y_list)
    if isequal(lim, []),  lim = {};  end
    assert(iscell(lim))
    assert(isnumeric(x_list))
    assert(isnumeric(y_list))
    num_patches = numel(lim);
    num_pixels  = numel(x_list);
    if (num_patches == 0)
        num_patches = 1;  % background is considered a patch, too.
        id = ones(num_pixels,1);
        return;
    end
    id = NaN(num_pixels,1);
    for i=1:num_patches
        if isvector(lim{i}) && (numel(lim{i}) == 4)
            lim{i} = struct('x_lim',lim{i}(1:2), 'y_lim',lim{i}(3:4));
        end
        if isempty(lim{i})
            idx = true(size(id));
        elseif isfield(lim{i}, 'x_lim') && isfield(lim{i}, 'y_lim')
            idx = lim{i}.x_lim(1) <= x_list & x_list <= lim{i}.x_lim(2)...
                & lim{i}.y_lim(1) <= y_list & y_list <= lim{i}.y_lim(2);
        elseif isfield(lim{i}, 'x_pos') && isfield(lim{i}, 'y_pos')
            idx = inpolygon (x_list, y_list, lim{i}.x_pos, lim{i}.y_pos);
        else
            warning('snr:po:patch:unk', 'Unknown patch limits format (i=%d).', i);
            idx = [];
        end
        %sum(idx)  % DEBUG
        id(idx) = i;
    end
end

