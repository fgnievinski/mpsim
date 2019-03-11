function [result, snr_db, carrier_error, code_error] = snr_po1 (setup)
%SNR_PO1:  Physical Optics scattering for a single satellite direction.

    if ~isfield(setup, 'pre'),  setup.pre = struct();  end
    pre = setup.pre;
    [setup.opt, setup.sat] = snr_po1_opt (setup.opt, setup.sat);
    snr_po_mapform()
    %setup.opt.clear = false;  % DEBUG
    %setup.opt.apply_fraunhofer = false; % DEBUG
    %setup.opt.num_specular_max = Inf;  % DEBUG
    %pre  % DEBUG
    
    [delay, dA, graz_scatt, proj_scatt_normal, ...
     E_direct_rhcp, E_direct_lhcp, ...
     G_direct_rhcp, G_direct_lhcp, G_rhcp, G_lhcp, ...
     X_direct, X_incid, X_scatt, F_same, F_cross, ...
     K, I, S, L, L_direct, doppler, ...
     extra, pre] = snr_po1_aux (setup, pre);
    
    %% Direct voltage (at the receiver, pre-code modulation) [V]:
    V_direct_rhcp = G_direct_rhcp * E_direct_rhcp;
    V_direct_lhcp = G_direct_lhcp * E_direct_lhcp;
    V_direct_pre = V_direct_rhcp + V_direct_lhcp;
    %if setup.opt.clear,  clear G_direct_rhcp G_direct_lhcp;  end  % just scalars
    %if setup.opt.clear,  clear E_direct_rhcp E_direct_lhcp;  end  % just scalars

    %% Visibility:
    if ~L_direct
        if any(L)
            V_direct_pre = 0;  % allow for partial visibility.
        else
            V_direct_pre = NaN;  % disable solution
        end
    end
    
    %% Transmitted voltage (at the satellite) [V]:
    V_trans_rhcp = E_direct_rhcp ./ X_direct;
    V_trans_lhcp = E_direct_lhcp ./ X_direct;
    %if setup.opt.clear,  clear X_direct;  end  % just a scalar

    %% Incident electric field (on the surface) [V/m]:
    E_incid_rhcp = X_incid .* V_trans_rhcp;
    E_incid_lhcp = X_incid .* V_trans_lhcp;
    if setup.opt.clear,  clear X_incid V_trans_rhcp V_trans_lhcp;  end

    %% Scattered electric field (isotropic, leaving the surface) [V/m]:
    E_scatt0_rhcp = F_same .* E_incid_rhcp + F_cross .* E_incid_lhcp;
    E_scatt0_lhcp = F_same .* E_incid_lhcp + F_cross .* E_incid_rhcp;
    if setup.opt.clear,  clear E_incid_rhcp E_incid_lhcp F_same F_cross;  end
    
    %% Scattered electric field (directed, arriving at the receiving antenna) [V/m]:
    temp = - X_scatt .* K .* dA;
    if setup.opt.apply_proj_scatt_normal,  temp = temp ./ proj_scatt_normal;  end
    E_scatt_rhcp = temp .* E_scatt0_rhcp;
    E_scatt_lhcp = temp .* E_scatt0_lhcp;
    if setup.opt.clear,  clear temp K X_scatt E_scatt0_rhcp E_scatt0_lhcp;  end

    %% Sub-pixel parameterized effects:
    temp = I .* S .* L .* extra.info.truncation_factor;
    if any(strcmpi(setup.opt.apply_taper, {'before','pre'})) ...
    && ~isinf(setup.opt.taper_gaussian_sigma_in_pixels)
        temp = temp .* pre.taper;
    end
    if setup.opt.clear,  clear S L;  end
    E_scatt_rhcp = temp .* E_scatt_rhcp;
    E_scatt_lhcp = temp .* E_scatt_lhcp;
    if setup.opt.clear,  clear temp;  end

    %% Scattering voltage (pre-code modulation) [V]:
    V_rhcp = G_rhcp .* E_scatt_rhcp;
    V_lhcp = G_lhcp .* E_scatt_lhcp;
    if setup.opt.clear,  clear G_rhcp G_lhcp E_scatt_rhcp E_scatt_lhcp;  end
    V_pre = V_rhcp + V_lhcp;
    if setup.opt.clear,  clear V_rhcp V_lhcp;  end
    
    %% Tapering:
    if any(strcmpi(setup.opt.apply_taper, {'after','post'})) ...
    && ~isinf(setup.opt.taper_gaussian_sigma_in_pixels) ...
    && ~isscalar(pre.psf)
        %tic
        if ~isinf(setup.opt.num_specular_max) ...
        && ~isinf(setup.opt.fresnel_zone_max)
            V_pre_map = zeronan(snr_po_mapform(V_pre));
            V_pre_map = cedgetaper(V_pre_map, pre.psf);
            %V_pre = V_pre_map(extra.info.idx_keep);  % WRONG!
            V_pre = reshape(V_pre_map, [extra.info.num_elements_original 1]);
            V_pre = V_pre(extra.info.idx_keep,:);
        else
            V_pre_map = reshape(V_pre, extra.info.siz);
            V_pre_map = cedgetaper(V_pre_map, pre.psf);
            V_pre = reshape(V_pre_map, [extra.info.num_elements 1]);
        end
        %toc  % DEBUG
    end
    
    %% Reflection biases (for consistency with GO -- see snr_fwd.m):
    % (For a physically-based alternative, use sett.ref.height_off.)
    geom2 = struct();
    %geom2.direct.dir.local_ant.elev = elev_sat;  % WRONG!
    geom2.direct.dir.local_ant.elev = setup.opt.elev_sat_direct;
    geom2.reflection.sat_dir.sfc.elev = graz_scatt;    
    [V_direct_pre, extra.phasor_bias_direct, ...
     V_pre, extra.phasor_bias_reflected, ...
     delay, extra.delay_bias] = snr_fwd_bias (...
        V_direct_pre, V_pre, delay, setup, geom2);

    %% Code modulation:
    row = @(x) rowvec(x, 'force');
    [power_composite, carrier_error, code_error, extra2] = snr_fwd_combine (...
        setup.opt, V_direct_pre, row(V_pre), row(delay), row(doppler));
        %setup.opt, V_direct_pre, V_pre(:)', delay(:)', doppler(:)');  % WRONG! should not complex-conjugate.
    if setup.opt.clear,  clear V_pre;  end
    if setup.opt.clear,  clear delay;  end

    %% Post-code modulation voltages:
    phasor_direct    = extra2.phasor_direct;
    %phasor_reflected = extra2.phasor_reflected;
    phasor_reflected = extra2.reflected.phasor_post_net;  % scalar
    phasor_scattered = extra2.reflected.phasor_post_all;  % grid
    phasor_composite = extra2.phasor_composite;
    phasor_error     = extra2.phasor_error;
    phasor_interf    = extra2.phasor_interf;
    C = extra2.reflected.code;
    C_direct = extra2.direct.code;
    
    %% Signal-to-noise ratio:
    geom2 = struct();
    geom2.direct.dir.local_ant.elev = setup.opt.elev_sat_direct;
    geom2.reflection.sat_dir.sfc.elev = graz_scatt;    
    [snr_db, extra.power_loss] = snr_fwd_signal2snr (power_composite, ...
        setup, geom2, extra.phasor_bias_direct);
    
    %% Pack main results:
    result = extra;
    result.pre = pre;
    result.phasor_direct    = phasor_direct;
    result.phasor_reflected = phasor_reflected;
    result.phasor_composite = phasor_composite;
    result.phasor_interf    = phasor_interf;
    result.phasor_error     = phasor_error;
    result.snr_db           = snr_db;
    result.power_composite  = power_composite;
    result.carrier_error    = carrier_error;
    result.code_error       = code_error;
    
    result.epoch = setup.sat.epoch;
    result.azim  = setup.sat.azim;
    result.elev  = setup.sat.elev;
    
    result.map.phasor_scattered = snr_po_mapform(phasor_scattered);
    result.map.phasor = result.map.phasor_scattered;  % legacy interface.
    if ~setup.opt.clear
        % TODO: mimic snr_fwd.m
        result.map.phasor_rhcp = snr_po_mapform(V_rhcp);
        result.map.phasor_lhcp = snr_po_mapform(V_lhcp);
        result.map.C = snr_po_mapform(C);
        result.map.C_direct = snr_po_mapform(C_direct);
    end
    result.info.wavelength = result.opt.wavelength;  % legacy interface.
    
    result.opt_po = structmergenonempty(setup.opt.po, getfields(setup.opt, fieldnames(setup.opt.po)));
end

%%
function opt = snr_po1_opt_default ()
    opt = struct();
    opt.dist_sat_direct = 20e6;
    opt.patch_lim = {};
    opt.approximate_dir_sat = true;
    opt.use_two_angle_roughness = false;
    opt.account_for_2nd_obliquity = false;
    opt.apply_fraunhofer = true;
    opt.plotit = false;
    opt.clear = false;
    opt.clear = true;
    opt.lim = 10;
    opt.step_in_wavelengths = 1/3;
    opt.zero_center_domain = true;
    opt.do_full_pre = [];
    opt.fresnel_zone_max = 1;
    opt.num_specular_max = 3;
    opt.taper_gaussian_sigma_in_pixels = 2;
    opt.taper_gaussian_sigma_in_pixels = Inf;
    opt.taper_gaussian_hsize_in_sigmas = 3;
    opt.apply_taper = 'never';  % 'pre'/'before', 'post'/'after', 'none'/'never'
    opt.apply_proj_scatt_normal = false;
    opt.check_mistrunc = true;
end

%%
function [opt, sat] = snr_po1_opt (opt, sat)
    opt = structmerge(opt, opt.po);
    %opt = structmergenonempty(snr_po1_opt_default(), opt);  % WRONG!  too soon.
    %opt = check_opt_aux2 (opt);
    
    if (~isempty(opt.num_specular_max) && ~isinf(opt.num_specular_max)) ...
    && (~isempty(opt.fresnel_zone_max) &&  isinf(opt.fresnel_zone_max))
        if ~isempty(opt.fresnel_zone_max)
          warning('snr:snr_po1:spm', ...
             ['Stationary-phase method ineffective with finite ' ...
              '"num_specular_max" and infinite "fresnel_zone_max"; forcing  ' ...
              'fresnel_zone_max = 1;']);
        end
        opt.fresnel_zone_max = 1;
    elseif (~isempty(opt.num_specular_max) &&  isinf(opt.num_specular_max)) ...
        && (~isempty(opt.fresnel_zone_max) && ~isinf(opt.fresnel_zone_max))
%         if ~isempty(opt.fresnel_zone_max)
%           warning('snr:snr_po1:spm', ...
%              ['Stationary-phase method ineffective with finite ' ...
%               '"fresnel_zone_max" and infinite "num_specular_max"; forcing ' ...
%               'num_specular_max = 1;']);
%         end
        opt.num_specular_max = 1;
    end

    opt = structmergenonempty(snr_po1_opt_default(), opt);
    opt = check_opt_aux2 (opt);
    
    if ~isscalar(sat.elev) || ~isscalar(sat.azim)
        warning('snr:snr_po1:multipleDir', ...
           'Multiple target directions detected; ignoring all but the first one.');
        sat = snr_setup_sat_simple (sat.epoch(1), sat.azim(1), sat.elev(1));
    end
    opt.elev_sat_direct = sat.elev;
    opt.azim_sat_direct = sat.azim;
    
    if isfieldempty(opt, 'num_dirs')
        %warning('snr:snr_po1:singleDirReally', ...
        %   'Undefined opt.num_dirs; assuming single direction.');
        opt.num_dirs = 1;
    end
    if (opt.num_dirs == 1) && isinf(opt.num_specular_max)
        % (opt.do_full_pre is inconsequential)
        % we're gonna sample all elements anyways.
    elseif (opt.num_dirs > 1) && isinf(opt.num_specular_max)
        opt.do_full_pre = true;  % speed-up is certain.
        % we're gonna sample all elements multiple times.
    elseif (opt.num_dirs == 1) && ~isinf(opt.num_specular_max)
        opt.do_full_pre = false;  % speed-up is certain.
        % we're NEVER gonna sample some of the elements.
    elseif (opt.num_dirs > 1) && ~isinf(opt.num_specular_max)
        % this is the only case that would benefit from the user's judgement;
        % recommendations are as follows:
        % - many and widely spread directions: do full pre-processing
        % - few and narrowly concentrated directions: don't do full pre-proc.
        % The gray area lies in between these two extremes.
        % (leave it up to the user.)
    end
    if isempty(opt.do_full_pre),  opt.do_full_pre = true;  end  % (unless she abstained from deciding.)
    opt.wavenumber = 2*pi / opt.wavelength;
    opt.dir_up = [0 0 1];
end

%%
function opt = check_opt_aux2 (opt)
    opt = check_opt_aux (opt, 'step');
    opt.taper_gaussian_hsize_in_pixels = ...
    opt.taper_gaussian_hsize_in_sigmas * ...
    opt.taper_gaussian_sigma_in_pixels;
end
    
%%
function opt = check_opt_aux (opt, fn)
    fn2 = [fn '_in_wavelengths']; 
    %if ~isfieldempty(opt, fn2)
        if ~isfieldempty(opt, fn)
            warning('snr:snr_po1:twoFields', ...
               'Non-empty "%s" detected; ignoring it in favor of "%s".', fn, fn2);
        end
        opt.(fn) = opt.(fn2) * opt.wavelength;
    %end
end

%%
function pre = snr_po_pre_scatt2 (pre, info, setup)
    temp = {'X_scatt', 'graz_scatt', 'elev_sfc', 'azim_sfc', 'L_scatt', 'L_scatt2'};
    if none(cellisfieldempty(pre, temp))
        return;
    end

    %% Green's function [1/m, or 1/(sr*m)]:
    pre.X_scatt = 1/(4*pi) .* phasor_init(1./pre.dist_scatt, 360*pre.dist_scatt./setup.opt.wavelength);
    % use phasor_init to guarantee consistency with get_permittivity,
    % with regard to sign of imaginary part of complex numbers:

    % Grazing angle of the scattered direction w.r.t. the surface osculating plane [degrees]:
    % Also cosine of angle between scattering direction and surface normal direction [unitless]:
    % (also known as projection of the surface normal direction in the scattering direction)
    [pre.graz_scatt, ~, pre.proj_scatt_normal] = convert_dir_local2sfc_grazing (pre.dir_scatt, pre.dir_normal);
    
    % Anti-scattered direction (from receiver to surface):
    dir_scatt_recip = -pre.dir_scatt;  % [Cartesian coordinates]
    dir_scatt_recip_sph = cart2sph_local(dir_scatt_recip);  % [spherical coordinates]
    % Elevation angle of the anti-scattered direction:
    pre.elev_sfc = dir_scatt_recip_sph(:,1);
    pre.azim_sfc = dir_scatt_recip_sph(:,2);
    clear dir_scatt_recip dir_scatt_recip_sph;

    %% Shadowing [indicator function]:
    pre.L_scatt = (pre.graz_scatt > 0);
     
    %% Occlusion [indicator function]:
    setup.opt.occlusion.type = 'scattered';
    pre.L_scatt2 = snr_po_occlusion (pre, info, setup, pre.L_scatt);
end

%%
function pre = snr_po_pre_ant (pre, info, setup) %#ok<INUSL>
    %% Antenna effective length [m]:
    if ~isfieldempty(pre, 'G_rhcp') ...
    && ~isfieldempty(pre, 'G_lhcp')
        return;
    end

    geom2 = struct();
    geom2.reflection.dir.local_ant.elev = pre.elev_sfc;
    geom2.reflection.dir.local_ant.azim = pre.azim_sfc;
    geom2.reflection.dir.ant = setup.ant.snr_fwd_direction_local2ant (...
        geom2.reflection.dir.local_ant, setup);
    [pre.G_rhcp, pre.G_lhcp] = snr_fwd_antenna ('reflected', geom2, setup);
end

%%
function is_visible = snr_po_occlusion (pre, info, setup, is_visible_pre)
    if (pre.num_patches > 1)
        if isfield(pre, 'pos_sfc_original')
            pos_sfc = pre.pos_sfc_original;
        else
            pos_sfc = pre.pos_sfc;
        end
        setup.sfc = struct();
        setup.sfc.snr_fwd_geometry_sfc_height = @(pos_horz, setup) ...
            interp2(info.x_domain, info.y_domain, ...
            reshape(pos_sfc(:,3), info.siz), ...
            pos_horz(:,2), pos_horz(:,1));
            %pos_horz(:,1), pos_horz(:,2));  % WRONG!
    end
    geom = struct();
    switch lower(setup.opt.occlusion.type)
    case 'scattered'
        geom.num_dirs = info.num_elements;        
        geom.reflection.pos.local.cart   = pre.pos_sfc;
        geom.reflection.extra.dir_scatt  = pre.dir_scatt;
        geom.reflection.extra.dist_scatt = pre.dist_scatt;
        is_visible = snr_fwd_occlusion (setup, geom, is_visible_pre);
    case 'incident'
        geom.num_dirs = info.num_elements;        
        geom.reflection.pos.local.cart = pre.pos_sfc;
        geom.direct.dir.local_ant.cart = pre.dir_sat;
        if setup.opt.approximate_dir_sat
            geom.direct.dir.local_ant.cart = repmat(geom.direct.dir.local_ant.cart, [geom.num_dirs 1]);
        end
        setup.opt.occlusion.x_lim = info.x_lim;
        setup.opt.occlusion.y_lim = info.y_lim;
        is_visible = snr_fwd_occlusion (setup, geom, is_visible_pre);
    case 'direct'
        geom.num_dirs = 1;
        %setup.ref.pos_ant;
        geom.direct.dir.local_ant.cart = pre.dir_sat_direct;
        setup.opt.occlusion.x_lim = info.x_lim;
        setup.opt.occlusion.y_lim = info.y_lim;
        is_visible = snr_fwd_occlusion (setup, geom);
    end
end

%%
function pre = snr_po_pre2 (setup, pre, info)
    pre = snr_po_pre_scatt2 (pre, info, setup);
    pre = snr_po_pre_ant (pre, info, setup);
end

%%
function [pre2, pre, info] = snr_po_geom (setup, pre)
    [pre, info] = snr_po_pre (setup, pre);
    if setup.opt.do_full_pre
        pre = snr_po_pre2 (setup, pre, info);
    end
    pre2 = pre;  % pre cannot be modified, pre2 can.
    
    %% Receiver-satellite vector:
    pre2.dir_sat_direct = sph2cart_local([setup.opt.elev_sat_direct, setup.opt.azim_sat_direct, 1]);
    
    %% Propagation delay:
    [~, more] = snr_po_delay (pre2.pos_sfc, setup.ref.pos_ant, ...
        pre2.dir_sat_direct, setup.opt.dist_sat_direct, ...
        pre2.dist_scatt);
    pre2 = structmerge(pre2, more);

    %% Numerical stationary phase method.
    %setup.opt.plotit = true;  % DEBUG
    info.pos_specular = [];
    info.truncation_factor = 1;
    info.num_elements_original = info.num_elements;
    info.mistrunc = false;
    if ~isinf(setup.opt.num_specular_max) ...
    && ~isinf(setup.opt.fresnel_zone_max)
        snr_po_mapform([], info.siz, []);  % reset it.
        [info.pos_specular, info.idx_keep] = snr_po_spm (snr_po_mapform(pre2.delay), ...
            info.x_domain, info.y_domain, setup.opt.wavelength, ...
            setup.opt.num_specular_max, setup.opt.fresnel_zone_max);
        snr_po_mapform ([], [], info.idx_keep);
        %figure, spy(info.idx_keep)  % DEBUG
        % Check if integration is mistruncated at grid limits
        % (if so, try increasing sett.opt.lim):
        if setup.opt.check_mistrunc
            info.mistrunc = any(ismember(find(info.idx_keep(:)), ...
                get_border_ind(info.idx_keep)));
        end
        % Now keep only the elements within the first n Fresnel zones:
        mygetel = @(in, idx) iif ((size(in,1) ~= info.num_elements_original), @() in, @() in(idx,:));
        %mygetel = @(in, idx) iif (~isequal(size(in), info.siz), @() in, @() in(idx));  % WRONG!
        pre2 = structfun2(@(f) mygetel(f, info.idx_keep), pre2);
        info.truncation_factor = fresnel2factor (setup.opt.fresnel_zone_max);
        info.num_elements = sum(sum(info.idx_keep));
    end
    pre2.pos_sfc_original = pre.pos_sfc;

    if ~setup.opt.do_full_pre
        % only for the elements within the first n Fresnel zones:
        pre2 = snr_po_pre2 (setup, pre2, info);
    end
    
    %% Satellite direction (unit vector) at the surface (not at the receiver):
    if setup.opt.approximate_dir_sat
        % approximation valid for the (unity) direction, 
        % not for the sfc-sat distance or (non-unit) vector.
        pre2.dir_sat = pre2.dir_sat_direct;
        pre2.azim_sat = setup.opt.azim_sat_direct;
        pre2.elev_sat = setup.opt.elev_sat_direct;
        %(don't replicate, otherwise it'll make repeated interpolations)
        %dir_sat  = repmat(dir_sat,  [info.num_elements,1]);
        %elev_sat = repmat(elev_sat, [info.num_elements,1]);
        %azim_sat = repmat(azim_sat, [info.num_elements,1]);
    else
        pre2.dir_sat = divide_all(pre2.vec_sat, pre2.dist_sat);
        dir_sat_sph = cart2sph_local(pre2.dir_sat);
        pre2.azim_sat = dir_sat_sph(:,2);
        pre2.elev_sat = dir_sat_sph(:,1);
    end
    
    %% Incident direction (anti surface-to-satellite direction):
    %geom.dir_incid = -geom.dir_sat;  (not really needed)
    pre2.dist_incid = pre2.dist_sat;  % distance along a direction has no head or tail.
    %if setup.opt.clear,  pre2 = rmfield(pre2, 'dist_sat');  end  % WRONG! need it in account_for_2nd_obliquity

    %% Scattering vector (bisecting scattered and anti-incident dir):
    %% (not to be confused with scattered vector, from surface to antenna)
    pre2.vec_scattering = setup.opt.wavenumber * add_all(pre2.dir_scatt, pre2.dir_sat);  % = setup.opt.wavenumber * (dir_scatt - dir_incid);
    
    %% Second-order scattering vector:
    %setup.opt.account_for_2nd_obliquity = true;  % DEBUG
    if setup.opt.account_for_2nd_obliquity
        dir_scatt2 = divide_all(pre2.vec_scatt, pre2.dist_scatt.^2);
        dir_sat2   = divide_all(pre2.vec_sat,   pre2.dist_sat.^2);
        pre2.vec_scattering2 = add_all(dir_scatt2, dir_sat2);
        if setup.opt.clear,  clear dir_scatt2 dir_sat2;  end
    else
        pre2.vec_scattering2 = [0 0 0];
    end

    %% Satellite direction expressed in the surface osculating coordinate system:
    pre2.graz_sat = convert_dir_local2sfc_grazing (pre2.dir_sat, pre2.dir_normal);
end

%%
function [...
delay, dA, graz_scatt, proj_scatt_normal, ...
E_direct_rhcp, E_direct_lhcp, ...
G_direct_rhcp, G_direct_lhcp, G_rhcp, G_lhcp, ...
X_direct, X_incid, X_scatt, F_same, F_cross, ...
K, I, S, L, L_direct, doppler, ...
extra, pre] = snr_po1_aux (setup, pre)
    [geom, pre, info] = snr_po_geom (setup, pre);
    delay = geom.delay;
    dA = geom.dA;
    graz_scatt = geom.graz_scatt;
    proj_scatt_normal = geom.proj_scatt_normal;
    doppler = NaN(size(delay));  % TODO: bistatic Doppler
    
    %% Obliquity factor [1/m]:
    %if all(ismember(geom.dir_normal, setup.opt.dir_up, 'rows'))
    if isequal(geom.dir_normal, setup.opt.dir_up)
        K1 = geom.vec_scattering(:,3);
        K2 = geom.vec_scattering2(:,3);
    else
        K1 = dot_all(geom.vec_scattering,  geom.dir_normal);
        K2 = dot_all(geom.vec_scattering2, geom.dir_normal);
    end
    if setup.opt.clear && isfield(geom, 'vec_scattering2'),  geom = rmfield(geom, 'vec_scattering2');  end
    K = 1i.*K1 + K2;
    if setup.opt.clear,  clear K1 K2;  end

    %% Element-wise Fraunhofer approximation:
    if setup.opt.apply_fraunhofer
        temp = geom.vec_scattering(:,1:2);
        temp = temp + multiply_all(geom.vec_scattering(:,3), geom.vec_zgrad);
        temp = multiply_all(temp, xyz2neu(info.x_step, info.y_step)./2);
        temp = sincnopi(temp);
        %I = sum(temp, 2);  % WRONG!
        I = prod(temp, 2);
        if ~setup.opt.clear
            temp = neu2xyz(temp);
            Ix = temp(:,1);
            Iy = temp(:,2);
        end
        clear temp
    else
        I = 1;
        if ~setup.opt.clear
            Ix = NaN;
            Iy = NaN;
        end
    end
    if setup.opt.clear,  geom = rmfield(geom, 'vec_scattering');  end
    
    %% Surface roughness [unitless]:
    temp = [];  if setup.opt.use_two_angle_roughness,  temp = geom.graz_scatt;  end
    if (geom.num_patches == 1)
        S = get_roughness (setup.sfc.height_std, setup.opt.wavelength, geom.graz_sat, temp);
    else
        temp2 = @(i,idx) get_roughness (setup.sfc{i}.height_std, setup.opt.wavelength, ...
            getel_ifnotscalar(geom.graz_sat, idx), ...
            getel_ifnotscalar(temp, idx));
        S = get_patches_filled (temp2, geom.patch_id, geom.num_patches);
        clear temp2
    end
    clear temp

    %% Shadowing [indicator function]:
    L_scatt = geom.L_scatt;
    L_incid = (geom.graz_sat > 0);
    L = L_incid & L_scatt;
    if setup.opt.clear,  clear L_scatt;  end
    if setup.opt.clear,  geom = rmfield(geom, 'graz_scatt');  end
    %L = 1;  % DEBUG

    %% Occlusion [indicator function]:
    L_scatt2 = geom.L_scatt2;
    setup.opt.occlusion.type = 'incident';
    L_incid2 = snr_po_occlusion (geom, info, setup, L_incid);
    L2 = L_incid2 & L_scatt2;
    if setup.opt.clear,  clear L_incid L_incid2 L_scatt2;  end
    L = L & L2;

    %% Green's functions [1/m, or 1/(sr*m)]:
    X_scatt  = geom.X_scatt;
    X_incid  = 1/(4*pi) .* phasor_init(1./geom.dist_incid, 360*geom.dist_incid./setup.opt.wavelength);
    X_direct = 1/(4*pi) .* phasor_init(1./setup.opt.dist_sat_direct, 360*setup.opt.dist_sat_direct./setup.opt.wavelength);
    %X_direct = 1/(4*pi) .* phasor_init(1./dist_sat, 360*dist_sat./setup.opt.wavelength);  % WRONG!
    % use phasor_init to guarantee consistency with get_permittivity,
    % with regard to sign of imaginary part of complex numbers:

    %% Fresnel reflection coefficient [unitless]:
    geom2 = struct();
    geom2.reflection.sat_dir.sfc.elev = geom.graz_sat;
    %geom2.direct.dir.sfc.elev = geom.elev_sat;  % WRONG!
    if (geom.num_patches == 1)
        [F_same, F_cross] = snr_fwd_fresnelcoeff (geom2, setup);
    else
        [F_same, F_cross] = deal2(get_patches_filled (@doit, ...
            geom.patch_id, geom.num_patches, 2));
    end
    if setup.opt.clear,  geom = rmfield(geom, 'graz_sat');  end
    function out = doit (i, idx)
        geom3 = geom2();
        if ~geom.is_z_uniform || ~setup.opt.approximate_dir_sat
            geom3.reflection.sat_dir.sfc.elev(~idx) = [];
        end
        setupi = setfield(setup, 'sfc',setup.sfc{i});
        [temp1, temp2] = snr_fwd_fresnelcoeff(geom3, setupi);
        out = [temp1, temp2];
    end

    %% Antenna effective length [m]:
    G_rhcp = geom.G_rhcp;
    G_lhcp = geom.G_lhcp;
    geom2 = struct();
   %geom2.direct.dir.local_ant.elev = geom.elev_sat;  % WRONG!
   %geom2.direct.dir.local_ant.azim = geom.azim_sat;  % WRONG!
    geom2.direct.dir.local_ant.elev = setup.opt.elev_sat_direct;
    geom2.direct.dir.local_ant.azim = setup.opt.azim_sat_direct;
    geom2.direct.dir.ant = setup.ant.snr_fwd_direction_local2ant (...
        geom2.direct.dir.local_ant, setup);
    [G_direct_rhcp, G_direct_lhcp] = snr_fwd_antenna ('direct', geom2, setup);
    clear geom2;  % avoid reusing it

    %% Direct electric field (at the receiver) [V/m]:
    geom2 = struct();
   %geom2.direct.dir.local_ant.elev = elev_sat;  % WRONG!
   %geom2.direct.dir.local_ant.azim = azim_sat;  % WRONG!
    geom2.direct.dir.local_ant.elev = setup.opt.elev_sat_direct;
    geom2.direct.dir.local_ant.azim = setup.opt.azim_sat_direct;
    [E_direct_rhcp, E_direct_lhcp] = snr_fwd_incident (geom2, setup);
    clear geom2;  % avoid reusing it

    setup.opt.occlusion.type = 'direct';
    L_direct = snr_po_occlusion (geom, info, setup);
    
    %% Pack intermediate results:
    extra = struct();
    extra.map = struct();
    extra.map.delay = snr_po_mapform(geom.delay);
    [x_list, y_list, z_list] = neu2xyz(geom.pos_sfc);
    extra.map.x = snr_po_mapform(x_list);
    extra.map.y = snr_po_mapform(y_list);
      clear x_list y_list
    if ~setup.opt.clear
        extra.map.z           = snr_po_mapform(z_list);
        extra.map.X           = snr_po_mapform(X_scatt .* X_incid);
        extra.map.K1          = snr_po_mapform(K1);
        extra.map.K2          = snr_po_mapform(K2);
        extra.map.Ix          = snr_po_mapform(Ix);
        extra.map.Iy          = snr_po_mapform(Iy);
        extra.map.F_same      = snr_po_mapform(F_same);
        extra.map.F_cross     = snr_po_mapform(F_cross);
        extra.map.F_rhcp      = snr_po_mapform(F_same  + F_cross * sqrt(setup.opt.incid_polar_power));
        extra.map.F_lhcp      = snr_po_mapform(F_cross + F_same * sqrt(setup.opt.incid_polar_power));
        extra.map.L_scatt     = snr_po_mapform(L_scatt);
        extra.map.L_incid     = snr_po_mapform(L_incid);
        extra.map.L_scatt2    = snr_po_mapform(L_scatt2);
        extra.map.L_incid2    = snr_po_mapform(L_incid2);
        extra.map.L           = snr_po_mapform(L);
        extra.map.L_direct    = snr_po_mapform(L_direct);
        extra.map.G_rhcp      = snr_po_mapform(G_rhcp);
        extra.map.G_lhcp      = snr_po_mapform(G_lhcp);
        extra.map.S           = snr_po_mapform(S);
        extra.map.dist_scatt  = snr_po_mapform(geom.dist_scatt);
        extra.map.dist_incid  = snr_po_mapform(geom.dist_incid);
        extra.map.elev_sfc    = snr_po_mapform(geom.elev_sfc);
        extra.map.azim_sfc    = snr_po_mapform(geom.azim_sfc);
        extra.map.elev_sat    = snr_po_mapform(geom.elev_sat);
        extra.map.azim_sat    = snr_po_mapform(geom.azim_sat);
        extra.map.graz_sat    = snr_po_mapform(geom.graz_sat);
        extra.map.patch_id    = snr_po_mapform(geom.patch_id);
        extra.map.dA          = snr_po_mapform(geom.dA);
        extra.map.doppler     = snr_po_mapform(doppler);
        extra.map.pos_sfc     = geom.pos_sfc;
        extra.map.dir_scatt   = geom.dir_scatt;
        extra.map.dir_scatt   = geom.dir_scatt;
        extra.geom = geom;
    end
    
    extra.info = info;
    extra.opt = setup.opt;
    extra.info.height_ant = setup.ref.height_ant;
    extra.info.elev = setup.opt.elev_sat_direct;
    extra.info.azim = setup.opt.azim_sat_direct;
end

%!test
%! % snr_po1()
%! test('snr_po')

