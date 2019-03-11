function [dir_refl_ant, pos_refl_ref, delay, doppler, extra] = ...
snr_fwd_geometry_reflection_horiz (dir_sat, order, setup)
    sfc = setup.sfc;
    if isempty(order),  order = 1;  end
    if (order > sfc.num_specular_max)
        error('snr:snr_fwd_geometry_reflection_horiz:Order', ...
            'Higher-order reflections are not supported in horizontal surfaces.')
    end
    %whos  % DEBUG
    
    [delay, sin_elev] = get_reflection_delay (sfc.height_ant_sfc, dir_sat.elev);
    doppler = snr_fwd_geometry_reflection_horiz_doppler (dir_sat, setup);

    dir_refl_ant = struct();
    dir_refl_ant.elev = -dir_sat.elev;
    dir_refl_ant.azim =  dir_sat.azim;
    
    extra = struct();
    %extra.vec_refl_ant.sph = cat(2, ...  % WRONG! dim might be mixed
    extra.vec_refl_ant.sph = bsxcat(2, ...
        dir_refl_ant.elev(:), ...
        dir_refl_ant.azim(:), ...
        sfc.height_ant_sfc ./ max(eps(), sin_elev(:))); % avoid div by zero at horizon.
        %sfc.height_ant_sfc ./ sin_elev(:));
    extra.vec_refl_ant.cart = sph2cart_local (extra.vec_refl_ant.sph);
    
    pos_refl_ref = struct();
    pos_refl_ref.cart = add_all(extra.vec_refl_ant.cart, setup.ref.pos_ant);
end

%%
function doppler = snr_fwd_geometry_reflection_horiz_doppler (dir_sat, setup)    
    elev = dir_sat.elev;  % = setup.sat.elev;
    height = setup.sfc.height_ant_sfc;
    %height = setup.ref.height_ant;  % WRONG!
    elev_rate = setup.sat.elev_rate;
    velocity = setup.ref.velocity;
    if isempty(velocity) ...
    || (~isempty(setup.opt.dsss.neglect_doppler) ...
              && setup.opt.dsss.neglect_doppler)
        doppler = NaN(size(elev));
        return;
    end
    doppler = get_reflection_doppler (height, elev, velocity, elev_rate, setup.opt.wavelength);
end

function doppler = get_reflection_doppler (height, elev, velocity, elev_rate, wavelength)
    % Recall: delay = 2.*height.*sind(elev);
    delay_rate_height = 2.*velocity.*sind(elev);
    delay_rate_elev   = 2.*height.*elev_rate.*cosd(elev).*pi/180;
    delay_rate = delay_rate_height + delay_rate_elev;
    doppler = delay_rate ./ wavelength;
end

%!shared
%! sett = snr_settings();
%! sett.sat.num_obs = 1;
%! sett.ref.height_ant = 2;
%! sett.ref.ignore_vec_apc_arp = true;
%! setup = snr_setup(sett);
%! myassert(setup.ref.pos_ant, [0 0 2])
%! sfc = setup.sfc;
%! rand('seed',0)

%!test
%! % normal incident signal.
%! dir_incident.elev = 90;
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = -90;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = [0, 0, 0];
%! delay = 2 * sfc.height_ant_sfc;
%! 
%! [dir_reflection2, pos_reflection2, delay2, extra2] = ...
%!     snr_fwd_geometry_reflection_horiz (...
%!     dir_incident, [], setup);
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -100*eps)
%! myassert(pos_reflection.cart, pos_reflection2.cart, -100*eps)
%! myassert(delay, delay2, -100*eps)

%!test
%! % grazing signal.
%! dir_incident.elev = 0;
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = 0;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = NaN(1,3);  % not defined; it's at infinity.
%! delay = 0;
%! 
%! [dir_reflection2, pos_reflection2, delay2, extra2] = ...
%!     snr_fwd_geometry_reflection_horiz (...
%!     dir_incident, [], setup);
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -100*eps)
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -100*eps)  % WRONG!
%! myassert(delay, delay2, -100*eps)

%!test
%! % incident signal at 45 degrees.
%! dir_incident.elev = 45;
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = -45;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = [NaN, NaN, 0];
%! delay = sqrt(2) * sfc.height_ant_sfc;
%! 
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_horiz (...
%!     dir_incident, [], setup);
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -100*eps)
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -100*eps)
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), -100*eps)
%! myassert(norm(pos_reflection2.cart(1:2)), sfc.height_ant_sfc, -100*eps)
%! myassert(delay, delay2, -100*eps)
