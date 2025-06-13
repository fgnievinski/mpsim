function [pre, info] = snr_po_pre (setup, pre)
%SNR_PO_PRE: Pre-calculate common intermediary results for snr_po.m
% 
% SEE ALSO: snr_po1, snr_po1/snr_po_pre2.

    if (nargin < 2),  pre = struct();  end
    info = snr_po_info (setup.opt);
    pre = snr_po_pre_xyz (setup, pre, info);
    pre = snr_po_pre_normal (pre, info);
    pre = snr_po_pre_area (pre, info);
    pre = snr_po_pre_scatt (pre, info, setup);
    pre = snr_po_pre_taper (pre, info, setup);
    %#ok<*INUSL,*INUSD>
end

%%
function info = snr_po_info (opt)
    info = struct();
    switch numel(opt.step)
    case 1
        info.x_step = opt.step;
        info.y_step = opt.step;
    case 2
        info.x_step = opt.step(1);
        info.y_step = opt.step(2);
    otherwise
        error('snr:po:info:badStep', ...
            'Bad number of elements (%d) in opt.step', numel(opt.step));
    end
    %info.step = (info.x_step + info.y_step) / 2;  % WRONG!
    info.step = [info.x_step, info.y_step];
    info.dA_horiz = info.x_step * info.y_step;

    %% map of pixels center coordinates:
    if isstruct(opt.lim)
        assert(all(isfield(opt.lim, {'x','y'})))
        info.x_lim = opt.lim.x;
        info.y_lim = opt.lim.y;
        if isscalar(info.x_lim),  info.x_lim = [-1,+1]*info.x_lim;  end
        if isscalar(info.y_lim),  info.y_lim = [-1,+1]*info.y_lim;  end        
    else
        switch numel(opt.lim)
        case 1
            info.x_lim = [-1,+1]*opt.lim;
            info.y_lim = info.x_lim;
        case 2
            info.x_lim = [-1,+1]*opt.lim(1);
            info.y_lim = [-1,+1]*opt.lim(2);
        case 4
            info.x_lim = opt.lim(1:2);
            info.y_lim = opt.lim(3:4);
        end
    end
    if (info.x_lim(2) < info.x_lim(1)) ...
    || (info.y_lim(2) < info.y_lim(1))
        error ('snr:po:pre:lim', 'Please check opt.lim.');
    end

    opt.zero_center_domain = opt.zero_center_domain ...
        && (info.x_lim(1) < 0 && 0 < info.x_lim(2)) ...
        && (info.y_lim(1) < 0 && 0 < info.y_lim(2));
    
    if opt.zero_center_domain
        info.x_domain = [...
            fliplr(-info.x_step:-info.x_step:info.x_lim(1)), ...
            ...%info.x_lim(1):-info.x_step:-info.x_step, ...  % WRONG!
            0, ...
            info.x_step:info.x_step:info.x_lim(2) ...
        ];
        info.y_domain = [...
            fliplr(-info.y_step:-info.x_step:info.y_lim(1)), ...
            ...%info.y_lim(1):-info.y_step:-info.y_step, ...  % WRONG!
            0, ...
            info.y_step:info.y_step:info.y_lim(2) ...
        ];
        % make sure it overbounds:
        if (info.x_domain(1) > info.x_lim(1)),  info.x_domain = [info.x_domain(1)-info.x_step, info.x_domain];  end
        if (info.y_domain(1) > info.y_lim(1)),  info.y_domain = [info.y_domain(1)-info.y_step, info.y_domain];  end
        if (info.x_domain(2) < info.x_lim(2)),  info.x_domain = [info.x_domain, info.x_domain(end)+info.x_step];  end
        if (info.y_domain(2) < info.y_lim(2)),  info.y_domain = [info.y_domain, info.y_domain(end)+info.y_step];  end
        info.x_lim = info.x_domain([1 end]);
        info.y_lim = info.y_domain([1 end]);
    else
        info.x_domain = info.x_lim(1):info.x_step:info.x_lim(2);
        info.y_domain = info.y_lim(1):info.y_step:info.y_lim(2);
        info.x_lim(2) = info.x_domain(end);
        info.y_lim(2) = info.y_domain(end);
    end

    %% helper functions to go from list to map form:
    info.x_num = length(info.x_domain);
    info.y_num = length(info.y_domain);
    info.siz = [info.y_num, info.x_num];
    info.num_elements = prod(info.siz);
    snr_po_mapform([], info.siz);
    %snr_po_mapforminv([], info.num_elements);
end

%%
function pre = snr_po_pre_xy (setup, pre, info)
    if ~isfieldempty(pre, 'x_list') && ~isfieldempty(pre, 'y_list')
        return;
    end

    %% List of pixels center coordinates:
    [x_map, y_map] = meshgrid(info.x_domain, info.y_domain);
    pre.x_list = snr_po_mapforminv(x_map);
    pre.y_list = snr_po_mapforminv(y_map);
    clear x_map y_map
end

%%
function pre = snr_po_pre_id (setup, pre, info)
    if ~isfieldempty(pre, 'patch_id')
        return;
    end

    %% Find out which pixels belong to each patch:
    [pre.patch_id, pre.num_patches] = get_patches_id (setup.opt.patch_lim, ...
        pre.x_list, pre.y_list);
    %if (numel(setup.sfc) ~= pre.num_patches)  % WRONG!
    if (numel(setup.sfc) < pre.num_patches)
        error('snr:snr_po_pre_xyz:sfcPerPatch', ...
            'Needs one surface structure per patch.');
    end
end

%%
function pre = snr_po_pre_z (setup, pre, info)
    if ~isfieldempty(pre, 'z_list') && ~isfieldempty(pre, 'is_z_uniform')
        return;
    end

    %% List and map of pixels z coordinate:
    pos_sfc_horiz = xyz2neu(pre.x_list, pre.y_list);
    if (pre.num_patches == 1)
        pre.z_list = setup.sfc.snr_fwd_geometry_sfc_height (pos_sfc_horiz, setup);
    else
        z_fnc = @(i,idx) setup.sfc{i}.snr_fwd_geometry_sfc_height (pos_sfc_horiz(idx,:), ...
            setfield(setup, 'sfc',setup.sfc{i})); %#ok<SFLD>
        pre.z_list = get_patches_filled (z_fnc, pre.patch_id, pre.num_patches);
    end
    idx = isnan(pre.z_list);
    if any(idx)
        warning('snr:snr_po_pre_xyz:zNaN', 'NaN found in Z grid; replacing with median height.');
        pre.z_list(idx) = nanmedian(pre.z_list);
    end
    pre.is_z_uniform = is_uniform(pre.z_list);
end

%%
function pre = snr_po_pre_pos (setup, pre, info)
    if ~isfieldempty(pre, 'pos_sfc')
        return;
    end
    pre.pos_sfc = xyz2neu(horzcat(pre.x_list, pre.y_list, pre.z_list));
    % replace old copies by pointers:
    pre.x_list = pre.pos_sfc(:,2);
    pre.y_list = pre.pos_sfc(:,1);
    pre.z_list = pre.pos_sfc(:,3);
    %pre = rmfield(pre, {'x_list','y_list','z_list'});
end

%%
function pre = snr_po_pre_xyz (setup, pre, info)
    if ~isfieldempty(pre, 'pos_sfc') && ~isfieldempty(pre, 'patch_id')
        return;
    end

    pre = snr_po_pre_xy  (setup, pre, info);
    pre = snr_po_pre_id  (setup, pre, info);
    pre = snr_po_pre_z   (setup, pre, info);
    pre = snr_po_pre_pos (setup, pre, info);
end
  
%%
function pre = snr_po_pre_normal (pre, info)
    dir_up = [0 0 1];
    %% Surface normal direction:
    if ~isfieldempty(pre, 'dir_normal') && ~isfieldempty(pre, 'vec_zgrad')
        return;
    end
    
    if pre.is_z_uniform
        pre.vec_zgrad = [0 0];
        pre.dir_normal = dir_up;
        %pre.sfc_rot = eye(3);
        return;
    end
    
    z_list = pre.pos_sfc(:,3);
    [zgradx_map, zgrady_map] = gradient(snr_po_mapform(z_list), ...
        info.x_domain, info.y_domain);
    pre.vec_zgrad = xyz2neu(zgradx_map(:), zgrady_map(:));
    vec_normal = [-pre.vec_zgrad, ones(info.num_elements,1)];
    pre.dir_normal = normalize_vec(vec_normal);
    %pre.sfc_rot = get_rotation_matrix5_local (dir_up, pre.dir_normal, true);
end

%%
function pre = snr_po_pre_area (pre, info)
    dir_up = [0 0 1];
    %% Pixel surface area [m^2]:
    if ~isfieldempty(pre, 'dA')
        return;
    end
    
    if pre.is_z_uniform
        pre.dA = info.dA_horiz;
    else
        % tilted vs. horizontal -- i.e., actual vs. projected -- surface area:
        pre.dA = info.dA_horiz ./ dot_all(pre.dir_normal, dir_up);
          %keyboard
    end
end

%%
function pre = snr_po_pre_scatt (pre, info, setup) %#ok<INUSL>
    if ~isfieldempty(pre, 'dir_scatt')  ...
    && ~isfieldempty(pre, 'dist_scatt')
        return;
    end

    % Scattered vector (position difference, away from surface, to receiver):
    % (not to be confused with scattering or bi-secting vector)
    pre.vec_scatt = subtract_all(setup.ref.pos_ant, pre.pos_sfc);  % = pos_ant - pos_sfc

    % Surface-receiver distance:
    pre.dist_scatt = sqrt(dot_all(pre.vec_scatt));

    % Scattered direction (unit vector):
    pre.dir_scatt = divide_all(pre.vec_scatt, pre.dist_scatt);
    %pre = rmfield(pre, 'vec_scatt');  % WRONG! needed in account_for_2nd_obliquity
    
    if ~isfieldempty(pre, 'dist_scatt_original')
        pre.dir_scatt = pre.dir_scatt_original;  % (used by snr_po_dpdh.m)
    end
end

%%
function pre = snr_po_pre_taper (pre, info, setup) %#ok<INUSL>
    if ~isfieldempty(pre, 'taper') ...
    && ~isfieldempty(pre, 'psf') ...
    && strcmpi(pre.apply_taper, setup.opt.apply_taper) ...
    && strcmpi(pre.taper_gaussian_sigma_in_pixels, ...
         setup.opt.taper_gaussian_sigma_in_pixels) ...
    && strcmpi(pre.taper_gaussian_hsize_in_pixels, ...
         setup.opt.taper_gaussian_hsize_in_pixels)
        return;
    end
    pre.apply_taper = setup.opt.apply_taper;
    pre.taper_gaussian_sigma_in_pixels = setup.opt.taper_gaussian_sigma_in_pixels;
    pre.taper_gaussian_hsize_in_pixels = setup.opt.taper_gaussian_hsize_in_pixels;

    if isinf(setup.opt.taper_gaussian_sigma_in_pixels)
        pre.psf = [];
        pre.taper = 1;
        return
    end
    
    pre.psf = snr_po_taper_psf (info, setup);
    
    if none(strcmpi(setup.opt.apply_taper, {'before','pre'}))
        pre.taper = NaN;
        return
    end

    if isscalar(pre.psf)
        pre.taper = 1;
        return
    end
        
    temp = zeros(info.siz);
    temp([1,end],:) = 1;
    temp(:,[1,end]) = 1;
    pre.taper = 1 - edgetaper(temp, pre.psf);
    %pre.taper = edgetaper(ones(info.siz), pre.psf);  % WRONG!
    
    pre.taper = pre.taper(:);
    
    %%
    return
    figure
      imagesc(info.x_lim, info.y_lim, reshape(pre.taper, info.siz))
      hline(setup.opt.taper_gaussian_hsize, '-k')
      hline(setup.opt.taper_gaussian_hsize, '-k')
      colorbar
      axis image
end
