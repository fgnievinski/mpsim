function sett = snr_deprecated (sett, list)
    if isempty(sett),  return;  end
    if (nargin < 2) || isempty(list),  list = get_list ();  end
    oldname = list.old;
    newname = list.new;
    if ~isfield(list, 'opt'),  list.opt = false(size(oldname));  end
    if ~isfield(list, 'fnc'),  list.fnc =  cell(size(oldname));  end
    optional = list.opt;
    n = numel(oldname);
    assert(numel(newname) == n)
    for i=1:n
        oldnamei = oldname{i};
        newnamei = newname{i};
        oldvali = evals (sett, oldnamei);
        if isempty(oldvali),  continue;  end
        if isempty(newnamei)
            newvali = [];
        elseif optional(i)
            newvali = evals (sett, newnamei);
        else
            newvali = eval (newnamei);  % faster
        end
        if isequaln(oldvali, newvali),  continue;  end
        %if ~isempty(oldvali) && (isempty(newnamei) || ~isequaln(oldvali, eval(newnamei)))
        
        msg1 = sprintf('Deprecated syntax "%s"', oldnamei);
        if isempty(newnamei)
            msg2a = ' (no equivalent setting exists)';
            msg2b = ';\nplease remove non-empty value.';
            msg2 = [msg2a msg2b];            
            fnc = @error;
        elseif isempty(newvali) ...
        || ( isstruct(oldvali) && isstruct(oldvali) )
            msg2 = sprintf(';\nplease use "%s" instead.', newnamei);
            fnc = @warning;
        else
            msg2a = ';\nplease remove non-empty value ';
            msg2b = sprintf('and/or use "%s" instead', newnamei);
            msg2c = ' (conflicting contents).';
            msg2 = [msg2a msg2b msg2c];
            fnc = @error;
        end
        msg = [msg1 msg2];
        fnc('snr:deprecated', msg);
        
        [fn,sn] = strtok2 (oldnamei, '.');  sn(end) = [];
        s = eval(sn);
        if isstruct(s) && ~isscalar(s)
            [fn2, sn2] = strtok2 (newnamei, '.');  sn2(end) = [];
            myassert(sn2, sn)
            eval(sprintf('%s = renfield(%s, ''%s'', ''%s'');', sn, sn, fn, fn2));
            continue;
        end
        
        eval([oldnamei ' = [];'])
        if isempty(newnamei),  continue;  end
        if isstruct(oldvali)
            temp2 = sprintf('structmergenonempty(%s, oldvali);', newnamei);
        else
            if ~isempty(list.fnc{i})
                oldvali = list.fnc{i}(oldvali); %#ok<NASGU>
            end
            temp2 = 'oldvali';
        end
        eval([newnamei ' = ' temp2 ';'])
        
        %if strfind(oldi, 'material'),  keyboard;  end  % DEBUG
    end
end

%%
function temp = evals (sett, oldi)
    fn = textscan(oldi, '%s', 'Delimiter','.');
    fn = fn{1};
    assert(strcmp(fn{1}, 'sett'))
    temp = sett;
    for i=2:numel(fn)
        if isfield(temp, fn{i})
            temp = temp.(fn{i});
        else
            temp = [];
            return;
        end
    end
end

% function temp = evals (sett, oldi)
%     try
%        temp = eval(oldi);
%     catch me
%        id = {'MATLAB:nonStrucReference', 'MATLAB:nonExistentField'};
%        if none(strcmp(me.identifier, id)),  rethrow(me);  end
%        temp = [];
%     end
% end

%%
function list = get_list ()
    persistent list2
    if isempty(list2),  list2 = get_list2 ();  end
    list = list2;
end

function list = get_list2 ()
    old = {};
    new = {};
    opt = [];  % is the new name an optional field?
    fnc = {};
    
    old{end+1} = 'sett.po';
    new{end+1} = 'sett.opt.po';
    opt(end+1) = false;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.po.z_fnc';
    new{end+1} = [];
    opt(end+1) = true;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.po.step';
    new{end+1} = [];
    opt(end+1) = true;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.po.dist_sat';
    new{end+1} = 'sett.opt.po.dist_sat_direct';
    opt(end+1) = true;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.spm.num_specular_max';
    new{end+1} = 'sett.opt.num_specular_max';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.po.spm.num_specular_max';
    new{end+1} = 'sett.opt.num_specular_max';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.po.spm.fresnel_zone_keep';
    new{end+1} = 'sett.opt.po.fresnel_zone_keep';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.zero_phase';
    new{end+1} = 'sett.opt.max_fringes';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.rec.disable_tracking_loss';
    new{end+1} = 'sett.opt.disable_tracking_loss';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.rec';
    new{end+1} = 'sett.opt.rec';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.rec.disable_tracking_loss';
    new{end+1} = 'sett.opt.disable_tracking_loss';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.ant_height_above_sfc';
    new{end+1} = 'sett.ref.height_ant';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.height_ant';
    new{end+1} = 'sett.ref.height_ant';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.ref.ant_height_above_sfc';
    new{end+1} = 'sett.ref.height_ant';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.ant_leverarmlen';
    new{end+1} = 'sett.ref.dist_arp_pivot';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.ignore_vec_apc_arp';
    new{end+1} = 'sett.ref.ignore_vec_apc_arp';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.vert_datum';
    new{end+1} = 'sett.sfc.vert_datum';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.ref.vert_datum';
    new{end+1} = 'sett.sfc.vert_datum';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.power_bias_fixed';
    new{end+1} = 'sett.bias.fixed';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.power_bias';
    new{end+1} = 'sett.bias.power';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.power_bias_reflected';
    new{end+1} = 'sett.bias.power_reflected';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.phase_bias_reflected';
    new{end+1} = 'sett.bias.phase_reflected';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.bias';
    new{end+1} = 'sett.bias';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.height_bias';
    new{end+1} = 'sett.bias.height';
    opt(end+1) = false;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.phase_bias';
    new{end+1} = 'sett.bias.phase_reflected';
    opt(end+1) = false;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.phase_approx_small';
    new{end+1} = 'sett.opt.phase_approx_small_power';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.cdma.approx_small';
    new{end+1} = 'sett.opt.cdma.approx_small_delay';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.polar_ellipticity_beta';
    new{end+1} = 'sett.opt.incid_polar_power';
    opt(end+1) = false;
    fnc{end+1} = @(x) x.^2;
    
    old{end+1} = 'sett.opt.incid_polar_magn';
    new{end+1} = 'sett.opt.incid_polar_power';
    opt(end+1) = false;
    fnc{end+1} = @(x) x.^2;
    
    old{end+1} = 'sett.ant.data_dir';
    new{end+1} = '';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.ant.switch_gain_left_right';
    new{end+1} = 'sett.ant.switch_left_right';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.sfc.material';
    new{end+1} = 'sett.sfc.material_bottom';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.sat.default_regular_in_sine';
    new{end+1} = 'sett.sat.regular_in_sine';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.elev_cutoff_direct';
    new{end+1} = 'sett.bias.fit.elev_lim_direct';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.elev_cutoff_reflected';
    new{end+1} = 'sett.bias.fit.elev_lim_reflected';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.fit.elev_cutoff_direct';
    new{end+1} = 'sett.bias.fit.elev_lim_direct';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.elev_cutoff_reflected';
    new{end+1} = 'sett.bias.elev_lim_reflected';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.degree_direct';
    new{end+1} = 'sett.bias.fit.degree_trend';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.degree_reflected';
    %new{end+1} = 'sett.bias.fit.degree_reflected';
    new{end+1} = 'sett.bias.fit.degree_reflected_aux';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.normalize';
    new{end+1} = 'sett.bias.fit.normalize';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.refine_peak';
    new{end+1} = 'sett.bias.fit.refine_peak';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.height_domain';
    new{end+1} = 'sett.bias.fit.height_domain';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.plotit';
    new{end+1} = 'sett.bias.fit.plotit';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.prefit_trend';
    new{end+1} = 'sett.bias.fit.prefit_trend';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.postfit_trend';
    new{end+1} = 'sett.bias.fit.postfit_trend';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.fit_fringe';
    %new{end+1} = 'sett.bias.fit.fit_fringe';
    new{end+1} = 'sett.bias.fit.trend_only';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.sfc.material_middle.param';
    new{end+1} = 'sett.sfc.material_middle.property_param';
    opt(end+1) = true;
    fnc{end+1} = [];

    old{end+1} = 'sett.sfc.material_middle.sample_depth';
    new{end+1} = 'sett.sfc.material_middle.property_depth';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.sfc.material_middle.sample_property';
    new{end+1} = 'sett.sfc.material_middle.property_sample';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.sfc.material_middle.property_value';
    new{end+1} = 'sett.sfc.material_middle.property_sample';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.power';
    new{end+1} = 'sett.bias.power_direct';
    opt(end+1) = false;
    fnc{end+1} = [];

    old{end+1} = 'sett.opt.jvec2phasor_convention';
    new{end+1} = '';
    opt(end+1) = false;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.opt.slot_num';
    new{end+1} = 'sett.opt.sat_num';
    opt(end+1) = false;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.opt.sat_prn';
    new{end+1} = 'sett.opt.sat_num';
    opt(end+1) = false;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.opt.sat_num';
    new{end+1} = [];
    opt(end+1) = false;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.opt.cdma';
    new{end+1} = 'sett.opt.dsss';
    opt(end+1) = false;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.phase_reflected';
    new{end+1} = 'sett.bias.phase_interf';
    opt(end+1) = true;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.bias.power_reflected';
    new{end+1} = 'sett.bias.power_interf';
    opt(end+1) = true;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.bias.fit.elev_reflected';
    new{end+1} = 'sett.bias.fit.elev_fringe';
    opt(end+1) = true;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.bias.fit.elev_direct';
    new{end+1} = 'sett.bias.fit.elev_trend';
    opt(end+1) = true;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.bias.fit.degree_direct';
    new{end+1} = 'sett.bias.fit.degree_trend';
    opt(end+1) = true;
    fnc{end+1} = [];    
    
    old{end+1} = 'sett.bias.fit.degree_reflected_aux';
    new{end+1} = 'sett.bias.fit.degree_fringe_aux';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.po.fresnel_zone_keep';
    new{end+1} = 'sett.opt.po.fresnel_zone_max';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.ant.height';
    new{end+1} = 'sett.ref.height_ant';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.max_fringes';
    new{end+1} = 'sett.opt.special_fringes';
    opt(end+1) = true;
    fnc{end+1} = @(max_fringes) iif(max_fringes, 'superior', []);
    
    old{end+1} = 'sett.opt.disable_fringes';
    new{end+1} = 'sett.opt.special_fringes';
    opt(end+1) = true;
    fnc{end+1} = @(disable_fringes) iif(disable_fringes, 'disable', []);
    
    old{end+1} = 'sett.opt.fringes_type';
    new{end+1} = 'sett.opt.special_fringes';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.opt.fringes_type';
    new{end+1} = 'sett.opt.special_fringes';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    old{end+1} = 'sett.bias.inv_ratio';
    new{end+1} = 'sett.bias.inv_ratio_fringe';
    opt(end+1) = true;
    fnc{end+1} = [];
    
    list = struct();
    list.old = old;  % old syntax
    list.new = new;  % new syntax
    list.opt = opt;  % is the new name an optional field?
    list.fnc = fnc;  % non-empty for non-trivial conversion.
end
