function [result, snr_db, carrier_error, code_error, pre] = snr_po (setup)
%SNR_PO: Physical Optics scattering for multiple satellite directions.

    if isfieldempty(setup, 'pre'),  setup.pre = struct();  end
    if isfieldempty(setup, 'field'),  setup.field = {};  end
    if ~iscell(setup.field) && isempty(setup.field),  setup.field = {};  end
    if ~iscell(setup.field) && ischar(setup.field),  setup.field = {setup.field};  end
    assert(iscell(setup.field))
    field_aux = snr_po_aux ();
    field_noaux = setdiff(setup.field, field_aux);
    field_default = {'phasor','delay','x','y'};  % see snr_po1.m
    setup.opt.po.clear = isempty(setup.field) || all(ismember(field_noaux, field_default));
    if isfieldempty(setup.opt.po, 'verbose'),      setup.opt.po.verbose = true;   end
    if isfieldempty(setup.opt.po, 'verbose_prc'),  setup.opt.po.verbose_prc = 5;  end
    if isfieldempty(setup.opt.po, 'single'),       setup.opt.po.single = false;   end
    %setup.opt.verbose = true;  % DEBUG

    siz = size(setup.sat.epoch);  setup.sat.epoch = setup.sat.epoch(:);
    num_dirs = prod(siz);
    setup.opt.po.num_dirs = num_dirs;  % (snr_po1.m needs this.)

    setup.sat_original = setup.sat;
    verbose = @(i) setup.opt.po.verbose && (i == 1 || i == num_dirs ...
        || is_multiple(i, round(num_dirs*setup.opt.po.verbose_prc/100)));
        %|| is_multiple(round(100*i/num_dirs), setup.opt.po.verbose_prc));  % WRONG!
    t0 = tic();
    for i=1:num_dirs
        t = tic();
        setup.sat.epoch = setup.sat_original.epoch(i);
        setup.sat.elev  = setup.sat_original.elev(i);
        setup.sat.azim  = setup.sat_original.azim(i);

        if verbose(i)
            fprintf('Elev:% 6.2f\t Azim:% 6.2f\t', setup.sat.elev, setup.sat.azim);
        end
        clear result1
        result1 = snr_po1 (setup);
        setup.pre = result1.pre;
        if verbose(i)
            extra = iif(result1.info.mistrunc, ' [mistrunc.]', '');
            fprintf('| %.2f min %.2f min %6.0f%%%s\n', ...
                toc(t)/60, toc(t0)/60, 100*i/num_dirs, extra);
        end
        %figure, imagesc(setup.opt.lim(1:2), setup.opt.lim(3:4), setup.pre.z_map), axis image, set(gca, 'YDir','normal'), grid on, colorbar

        resulti = getfields(result1, ...
            {'snr_db','carrier_error','code_error',...
            'phasor_composite','phasor_interf','phasor_error',...
            'phasor_direct','phasor_reflected'});
        resulti.info = result1.info;
        
        result1 = snr_po_aux (result1, setup.field);
        if isequal(setup.field, {'*'})
            resulti.map = result1.map;
        else
            resulti.map = getfields(result1.map, setup.field);
        end
        if setup.opt.po.single
            resulti.map = structfun(@single, resulti.map, 'UniformOutput',false);
        end
        
        resulti.opt_po = result1.opt_po;
        result(i) = resulti; %#ok<AGROW>
    end

    if (nargout < 2),  return;  end
    snr_db        = [result.snr_db];
    carrier_error = [result.carrier_error];
    code_error    = [result.code_error];
    snr_db        = reshape(snr_db, siz);
    carrier_error = reshape(carrier_error, siz);
    code_error    = reshape(code_error, siz);
    pre = setup.pre;
end

%%
function result = snr_po_aux (result, field)
    if (nargin < 1)
        result = {'ind_delay','ind_delay_inv','fresnel_zone',...
            'cphasor','mphasor','cmphasor','rphasor','radial','delay_grad','coh'};
        return
    end
    %if (nargin < 2) || isempty(field),  field = {'*'};  end  % WRONG!
    if (nargin < 2),  field = {'*'};  end
    if isempty(field),  return;  end
    if any(ismember(field, {'*','ind_delay','ind_delay_inv','fresnel_zone','cphasor','cmphasor'}))
        result = snr_po_cumul (result);
    end
    if any(ismember(field, {'*','mphasor','cmphasor'}))
        result = snr_po_filter (result);
        result.map.cmphasor = snr_po_accum (result.map.mphasor, ...
            result.map.ind_delay, result.map.ind_delay_inv, result.map.contiguous);
    end
    if any(ismember(field, {'*','ind_radius','ind_radius_inv','radius','rphasor'}))
        result = snr_po_radial (result);
    end
    if any(ismember(field, {'*','delay_grad'}))
        result = snr_po_delay_grad (result);
    end
    if any(ismember(field, {'*','coh'}))
        result = snr_po_coh (result);
    end
end

%%
%!test
%! num_pts = 50;
%! num_pts = 25;
%! %num_pts = 15;
%! elev_lim = [10, 30];
%! elev_lim = [10, 20];
%! lim = [-10,+10, -5,+25];
%! %lim = [-10,+10, -5,+40];
%! step_in_wavelengths = 1/2;  % faster
%! step_in_wavelengths = 1/3;  % more accurate
%! %step_in_wavelengths = 1/4;  % more accurate
%! %step_in_wavelengths = 1.5;
%! step_in_wavelengths = 2;
%! %step_in_wavelengths = 4;
%! %step_in_wavelengths = 10;
%! ant_model = 'TRM29659.00';  ant_radome = 'SCIT';  material_bottom = 'pec';
%! ant_model = 'TRM29659.00';  ant_radome = 'SCIT';  material_bottom = 'soil fixed';
%! %ant_model = 'isotropic';    ant_radome = '';  material_bottom = 'pec';
%! %ant_model = 'isotropic';    ant_radome = '';  material_bottom = 'soil fixed';
%! %ant_model = 'isotropic lhcp';    ant_radome = '';  material_bottom = 'pec';  % ZERO DIRECT
%! %ant_model = 'isotropic lhcp';    ant_radome = '';  material_bottom = 'soil fixed';  % ZERO DIRECT
%! %ant_model = 'isotropic rhcp';    ant_radome = '';  material_bottom = 'pec';  % ~ ZERO REFLECTION
%! %ant_model = 'isotropic rhcp';    ant_radome = '';  material_bottom = 'soil fixed';
%! dsss_disable = false;  % DEBUG
%! incid_polar_power = 0;
%! num_specular_max = [];  % DEBUG
%! %num_specular_max = 3;
%! fresnel_zone_max = 1;
%! apply_fraunhofer = false;  % DEBUG
%! apply_fraunhofer = true;
%! occlusion_disabled = true;  % DEBUG
%! %occlusion_disabled = false;
%! patched = false;  % DEBUG
%! patched = true;
%! %nonzero_biases = false;  % DEBUG
%! nonzero_biases = true;
%! taper_gaussian_sigma_in_pixels = Inf;
%! taper_gaussian_sigma_in_pixels = 3;
%! apply_taper = 'none';
%! %apply_taper = 'post';
%! %apply_taper = 'pre';
%! 
%! elev = linspace(elev_lim(1), elev_lim(2), num_pts)';
%! azim = 0; %-45; %45+180;
%! height = 2;
%! 
%! sett = snr_fwd_settings ();
%! sett.opt.po = struct();
%! sett.opt.po.lim = lim;
%! sett.opt.po.step_in_wavelengths = step_in_wavelengths;
%! sett.opt.po.apply_fraunhofer = apply_fraunhofer;
%! sett.opt.po.taper_gaussian_sigma_in_pixels = taper_gaussian_sigma_in_pixels;
%! sett.opt.po.apply_taper = apply_taper;
%! sett.opt.po.fresnel_zone_max = fresnel_zone_max;
%! sett.opt.num_specular_max = num_specular_max;
%! sett.opt.incid_polar_power = incid_polar_power;
%! sett.opt.dsss.disable = dsss_disable;
%! sett.sat.elev = elev;
%! sett.sat.azim = azim;
%! sett.ref.height_ant = height;
%! sett.sfc.material_bottom = material_bottom;
%! sett.ant.slope = 0;  sett.ant.aspect = 0;
%! sett.sfc.height_std = [];
%! sett.opt.incid_polar_magn = 0;
%! sett.opt.freq_name = 'L2';
%! sett.opt.code_name = 'L2C';
%! sett.opt.block_name = 'IIR-M';
%! sett.ant.model = ant_model;
%! sett.ant.radome = ant_radome;
%! sett.opt.occlusion.disabled = occlusion_disabled;
%! %%%sett.opt.apply_proj_scatt_normal = true;  % EXPERIMENTAL!
%! if nonzero_biases
%!    sett.bias.height = 0.1;
%!    sett.bias.phase_interf = 45;
%!    sett.bias.power_interf = 3;
%!    sett.bias.phase_direct = 15;
%!    sett.bias.power_direct = 1.1;
%! end
%! sett0 = sett;
%! setup0 = snr_setup(sett0);
%! 
%! sfc_case = {'horiz'};  % DEBUG
%! %sfc_case = {'tilted'};  % DEBUG
%! %sfc_case = {'dem-poly'};  % DEBUG
%! sfc_case = {'dem-grid'};  % DEBUG
%! %sfc_case = {'dem-grid-tilted'};  % DEBUG
%! %sfc_case = {'dem-grid-poly'};  % DEBUG
%! %%sfc_case = {'horiz', 'tilted', 'dem-poly', 'dem-grid'};
%! for i=1:numel(sfc_case)
%!   disp(sfc_case{i})  % DEBUG
%!   switch sfc_case{i}
%!   case 'horiz'
%!     sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_horiz;
%!     sett.sfc.slope = [];
%!   case 'tilted'
%!     sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
%!     sett.sfc.slope = 15;  sett.sfc.aspect = azim + 45;
%!   case 'dem-poly'
%!     sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
%!       sett.sfc.type = 'poly';
%!       sett.sfc.slope = [];
%!       sett.sfc.coeff = [0 0; 0 1]./100;
%!       sett.ref.ignore_vec_apc_arp = true;
%!   case 'dem-grid'
%!     sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
%!       sett.sfc.slope = [];
%!       sett.ref.ignore_vec_apc_arp = true;
%!       sett.opt.po.fresnel_zone_max = inf;
%!     sett2 = sett;
%!       % case 'dem-grid-poly':
%!       sett2.sfc.type = 'poly';
%!       sett2.sfc.coeff = [0 0; 0 1]./100;
%!       % case 'dem-grid-tilted':
%!       sett2.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
%!       sett2.sfc.slope = 5;  sett2.sfc.aspect = azim + 90;
%!     sett2.opt.po.clear = false;
%!     %sett2.opt.num_specular_max = Inf;
%!     %setup = snr_setup (sett2);
%!     setup = snr_resetup_check (sett2, setup0);
%!     s1 = warning('off', 'snr:snr_po1:multipleDir');
%!     s2 = warning('off', 'snr:snr_po1:singleDirReally');
%!     po_result = snr_po1 (setup);
%!     warning(s1)
%!     warning(s2)
%!     sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_dem;
%!       sett.sfc.type = 'grid';
%!       sett.sfc.PO_not_GO = true;
%!       sett.sfc.get_gradient = true;
%!       sett.sfc.get_hessian = true;
%!       sett.sfc.slope = [];
%!       sett.sfc.grid = struct('z',po_result.map.z, ...
%!         'x_domain',po_result.info.x_domain, 'y_domain',po_result.info.y_domain);
%!       sett.ref.ignore_vec_apc_arp = true;
%!   end
%! 
%!   sett2 = sett;
%!   if patched
%!     % a patch having the same height and material as the background is inconsequential:
%!     sett2.sfc = repmat({sett2.sfc}, [2 1]);
%!     sett2.opt.po.patch_lim = {[], lim./2};
%!   end
%!   %setup = snr_setup (sett2);
%!   setup = snr_resetup_check (sett2, setup0);
%!   
%!   [go_result, go_snr_db, go_carrier_error, go_code_error] = snr_fwd (setup);
%!   [po_result, po_snr_db, po_carrier_error, po_code_error] = snr_po  (setup);
%!   
%!   snr_units = 'dB';  snr_fnc = @(x) x;
%!   snr_units = 'W/W';  snr_fnc = @decibel_power_inv;
%!   figure
%!   subplot(3,1,1)
%!     hold on
%!     plot(setup.sat.elev, snr_fnc(po_snr_db), 'o-k')
%!     plot(setup.sat.elev, snr_fnc(go_snr_db), '.-r')
%!     grid on
%!     ylabel(sprintf('SNR (%s)', snr_units))
%!   subplot(3,1,2)
%!     hold on
%!     plot(setup.sat.elev, po_carrier_error*1000, 'o-k')
%!     plot(setup.sat.elev, go_carrier_error*1000, '.-r')
%!     grid on
%!     ylabel('Carrier error (mm)')
%!   subplot(3,1,3)
%!     hold on
%!     plot(setup.sat.elev, po_code_error*100, 'o-k')
%!     plot(setup.sat.elev, go_code_error*100, '.-r')
%!     grid on
%!     ylabel('Code error (cm)')
%!     xlabel('Elevation angle (degrees)')
%!   legend({'PO','GO'})
%!   mtit(sprintf('sfc geom: %s, antenna: %s/%s, material: %s', ...
%!     sfc_case{i}, ant_model, ant_radome, material_bottom))
%!   maximize()
%! 
%!   %[po_result1, po_snr_db1, po_carrier_error1, po_code_error1] = snr_po1 (setup);
%!   %keyboard  % DEBUG
%! end
