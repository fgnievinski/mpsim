function is_visible = snr_fwd_occlusion (setup, geom, is_visible_pre)
    setup.opt = set_opt (setup.opt);
    sfc = setup.sfc;
    opt = setup.opt;
    ref = setup.ref;
    if (nargin < 3) || isempty(is_visible_pre),  is_visible_pre = true(geom.num_dirs,1);  end
    if isscalar(is_visible_pre),  is_visible_pre = repmat(is_visible_pre, [geom.num_dirs 1]);  end
    if opt.occlusion.disabled || none(is_visible_pre)
        is_visible = is_visible_pre;
        return;
    end

    switch lower(opt.occlusion.type)
    case 'none'
        is_visible = is_visible_pre;
        return;
    case 'reflection'
        is_visible = is_visible_pre;
        setup.opt.occlusion.type = 'scattered';
        is_visible = snr_fwd_occlusion (setup, geom, is_visible);
        setup.opt.occlusion.type = 'incident';
        is_visible = snr_fwd_occlusion (setup, geom, is_visible);
        return;
    case 'direct'
        %pos = geom.pos.reflection;  % WRONG!
        pos = ref.pos_ant;
        dir = geom.direct.dir.local_ant.cart;
        pos = repmat(pos, [size(dir,1) 1]);
        dist_max = [];
    case 'incident'
        pos = geom.reflection.pos.local.cart;
        dir = geom.direct.dir.local_ant.cart;
        %dir = geom.reflection.sat_dir.local.cart;  % equivalent
        dist_max = [];
    case 'scattered'
        pos = geom.reflection.pos.local.cart;
        %if isequal(sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_dem)  % WRONG!
        if isfield(geom.reflection, 'extra') ...
        && all(isfield(geom.reflection.extra, {'dir_scatt','dist_scatt'}))
            dir = geom.reflection.extra.dir_scatt;
            dist_max = geom.reflection.extra.dist_scatt;
        else
            %dir = geom.reflection.dir.local_ant.cart;  % WRONG!
            dir = -geom.reflection.dir.local_ant.cart;  % from surface to receiver.
            dist_max = norm_all(minus_all(ref.pos_ant, pos));
        end
    otherwise
        error('snr:snr_fwd_occlusion:unk', 'Unknown opt.occlusion.type = "%s".', opt.occlusion.type);
    end
    
    step = opt.occlusion.step;

    if isempty(dist_max)
        if all(isfield(opt.occlusion, {'x_lim','y_lim'}))
            dist_max = intersect_ray_wall (pos, dir, opt.occlusion.x_lim, opt.occlusion.y_lim);
        elseif isequal(sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_dem) ...
        && strcmp(sfc.type, 'grid')
            dist_max = intersect_ray_wall (pos, dir, sfc.grid.x_lim, sfc.grid.y_lim);
        else
            dist_max = repmat(opt.occlusion.dist_max_direct, [geom.num_dirs 1]);
        end
    end

    if ~isempty(opt.occlusion.interp_method) ...
    && isequal(sfc.fnc_snr_setup_sfc_geometry, @snr_setup_sfc_geometry_dem) ...
    && strcmp(sfc.type, 'grid')
        sfc.method = opt.occlusion.interp_method;        
    end
    z_fnc = @(pos_horz) sfc.snr_fwd_geometry_sfc_height (pos_horz, setup);

    is_visible = get_occlusion (pos, dir, dist_max, step, z_fnc, is_visible_pre);
end

function opt = set_opt (opt)    
    occlusion_default.type = 'reflection';
    %occlusion_default.type = 'none';  % DEBUG
    occlusion_default.dist_max_direct = 100;
    occlusion_default.step = 5;
    occlusion_default.interp_method = '';
    if isfieldempty(opt, 'occlusion'),  opt.occlusion = struct();  end
    opt.occlusion = structmergenonempty(occlusion_default, opt.occlusion);
end

