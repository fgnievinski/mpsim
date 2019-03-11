function [dir_refl_ant, pos_refl_ref, delay, doppler, extra, optimizeit] = ...
snr_fwd_geometry_reflection_tilted (dir_sat, order, setup)
    sfc = setup.sfc;
    ref = setup.ref;
    if isempty(order),  order = 1;  end
    if (order > sfc.num_specular_max)
        error('snr:snr_fwd_geometry_reflection_tilted:Order', ...
            'Higher-order reflections are not supported in tilted surfaces.')
    end
    if isfieldempty(sfc, 'optimizeit'),  sfc.optimizeit = true;  end
    n = length(dir_sat.elev);
    optimizeit = sfc.optimizeit;
    if sfc.optimizeit && (sfc.slope == 0)
        temp = sfc.num_specular_max;
        setup.sfc = snr_setup_sfc_geometry_horiz (ref.pos_ant, sfc.pos_sfc0);
        setup.sfc.num_specular_max = temp;
        [dir_refl_ant, pos_refl_ref, delay, doppler, extra] = ...
            snr_fwd_geometry_reflection_horiz (dir_sat, order, setup);         
        return;
    end

    if ~isfield(dir_sat, 'cart')
        dir_sat.sph = [dir_sat.elev, dir_sat.azim, ones(n,1)];
        dir_sat.cart = sph2cart_local (dir_sat.sph);        
    end
    pos_ant_img = repmat(sfc.pos_ant_img, n,1);
    
    pos_ant_refl = proj_pt_line (ref.pos_ant, pos_ant_img, dir_sat.cart);
    %delay = norm_all(pos_ant_refl - pos_ant_img);  % WRONG! this will always be positive.
    delay = dot_all((pos_ant_refl - pos_ant_img), dir_sat.cart);
    doppler = NaN(size(delay));  % TODO
    
    %[vec_refl, is_line_facing_plane, is_degenerate] = intersect_line_plane (...
    %    pos_ant_img, dir_sat.cart, ...
    %    sfc.pos_sfc0, sfc.vec_nrml.cart);
    %pos_refl = vec_refl + repmat(ref.pos_ant, n,1);  % WRONG!
    [pos_refl_ref.cart, is_line_facing_plane, is_degenerate] = intersect_line_plane (...
        pos_ant_img, dir_sat.cart, ...
        sfc.pos_sfc0, sfc.vec_nrml.cart);
    vec_refl_ant.cart = minus_all (pos_refl_ref.cart, ref.pos_ant);
    
    dir_refl_ant.cart = normalize_all(vec_refl_ant.cart);
    dir_refl_ant.sph = cart2sph_local (dir_refl_ant.cart);
    dir_refl_ant.elev = dir_refl_ant.sph(:,1);
    dir_refl_ant.azim = dir_refl_ant.sph(:,2);
    dir_refl_ant.azim = azimuth_range_positive(dir_refl_ant.azim);

    extra = struct();
    extra.is_line_facing_plane = is_line_facing_plane;
    extra.is_degenerate = is_degenerate;
end

%%
%!test
%! %snr_fwd_geometry_reflection_tilted()
%! test snr_fwd_geometry_reflection_tilted_simple

%! % horizontal surface, normal incident signal.
%! % horizontal surface, perpendicular incident signal.
%! % horizontal surface, incident signal at 45 degrees.
%! % horizontal surface, random surface rise azimuth, ...
%! % ... random incident direction; vs. simpler implementation.
%! % tilted surface, normal incident signal (backward).
%! % tilted surface, incident signal at 45 degrees w.r.t. surface, forward.
%! % tilted surface, incident signal at 45 degrees w.r.t. surface, backward.

%%
%!shared
%! height = 2.1;
%! function setup = mysetup (slope, aspect, height, n)
%!   if (nargin < 3) || isempty(height),  height = evalin('caller','height');  end
%!   if (nargin < 4) || isempty(n),  n = 1;  end
%!   sett = snr_settings();
%!   sett.sat.num_obs = n;
%!   sett.ref.height_ant = height;
%!   sett.ref.ignore_vec_apc_arp = true;
%!   sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
%!   sett.sfc.slope  = slope;
%!   sett.sfc.aspect = aspect;
%!   setup = snr_setup(sett);
%!   myassert(setup.ref.pos_ant, [0 0 height])
%! end
%! slope = 0;
%! aspect = 0;
%! setup = mysetup (slope, aspect, height, 1);

%%
%!test
%! % horizontal surface, normal incident signal.
%! dir_incident.elev = 90;
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = -90;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = [0, 0, 0];
%! delay = 2 * height;
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! % reflection azimuth is understandably ill determined  
%! % for normal incidence, because the reflection point 
%! % has small horizontal coordinates.
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -100*eps)
%! %myassert(dir_reflection.azim, dir_reflection2.azim, -100*eps)
%! myassert(dir_reflection.elev, dir_reflection2.elev, -100*eps)
%! myassert(pos_reflection.cart, pos_reflection2.cart, -100*eps)
%! myassert(delay, delay2, -100*eps)

%%
%!test
%! % horizontal surface, perpendicular incident signal.
%! %dir_incident.elev = 0;  % WRONG! leads to degenerate case.
%! dir_incident.elev = sqrt(eps());
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = 0;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = [NaN, NaN, 0];
%! delay = 0;
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2, extra2] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%! myassert(~extra2.is_degenerate)
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! tol = -nthroot(eps(), 3);
%! myassert(dir_reflection.elev, dir_reflection2.elev, tol)
%! myassert(abs(azimuth_diff(dir_reflection.azim, dir_reflection2.azim)) < abs(tol))
%! %myassert(pos_reflection.cart, pos_reflection2.cart, tol)  % WRONG!
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), tol)
%! myassert(delay, delay2, tol)

%%
%!test
%! % horizontal surface, incident signal at 45 degrees.
%! dir_incident.elev = 45;
%! dir_incident.azim = randint(0,360);
%! dir_reflection.elev = -45;
%! dir_reflection.azim = dir_incident.azim;
%! pos_reflection.cart = [NaN, NaN, 0];
%! delay = sqrt(2) * height;
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%! 
%! %dir_reflection, dir_reflection2  % DEBUG
%! %pos_reflection, pos_reflection2  % DEBUG
%! %delay, delay2  % DEBUG
%! 
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -100*eps)
%! myassert(azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true) < nthroot(eps(),3))
%! myassert(dir_reflection.elev, dir_reflection2.elev, -100*eps)
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -100*eps)
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), -100*eps)
%! myassert(norm(pos_reflection2.cart(1:2)), height, -100*eps)
%! myassert(delay, delay2, -100*eps)

%%
%!test
%! % horizontal surface, random surface rise azimuth, 
%! % random incident direction; vs. simpler implementation.
%! n = ceil(1000*rand);
%! slope = 0;
%! aspect = randint(0,360);
%! setup = mysetup (slope, aspect, [], n);
%! 
%! dir_incident.elev = randint(0, 90, n,1);
%! dir_incident.azim = randint(0,360, n,1);
%! 
%! setup.sfc.optimizeit = true;
%! [dir_reflection, pos_reflection, delay, ...
%!  ignore, optimizeit] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%!   assert(optimizeit == true)
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2, ...
%!  ignore, optimizeit] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%!   assert(optimizeit == false)
%! 
%! %dir_reflection.elev, dir_reflection2.elev, dir_reflection2.elev - dir_reflection.elev % DEBUG
%! %dir_reflection.azim, dir_reflection2.azim, dir_reflection2.azim - dir_reflection.azim % DEBUG
%! %pos_reflection.cart, pos_reflection2.cart, pos_reflection2.cart - pos_reflection.cart  % DEBUG
%! %delay, delay2, delay2 - delay  % DEBUG
%! 
%! %max(abs(dir_reflection2.elev - dir_reflection.elev))  % DEBUG
%! %max(abs(dir_reflection2.azim - dir_reflection.azim))  % DEBUG
%! %max(abs(pos_reflection2.cart - pos_reflection.cart))  % DEBUG
%! %max(abs(delay2 - delay))  % DEBUG
%! %max(abs(mod(dir_reflection2.azim, 360) - mod(dir_reflection.azim, 360)))
%! 
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -nthroot(eps(),3))
%! myassert(azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true) < nthroot(eps(),3))
%! myassert(dir_reflection.elev, dir_reflection2.elev, -nthroot(eps(),3))
%! myassert(pos_reflection.cart, pos_reflection2.cart, -nthroot(eps(),3))
%! myassert(delay, delay2, -nthroot(eps(),3))

%%
%!test
%! % tilted surface, normal incident signal.
%! elev_sfc_rise = randint(0, 90);
%! azim_sfc_rise = randint(0,360);
%! slope = elev_sfc_rise;
%! aspect = azimuth_range_positive(azim_sfc_rise + 180);
%! setup = mysetup (slope, aspect);
%! 
%! dir_incident.elev = 180 - (slope + 90);
%! dir_incident.azim = aspect;
%! 
%! dir_reflection.elev = -dir_incident.elev;
%! dir_reflection.azim = azim_sfc_rise;
%! delayb = height * cosd(elev_sfc_rise);
%! delay = 2 * delayb;
%! pos_reflection.cart = [NaN, NaN, ...
%!     height - delayb * cosd(elev_sfc_rise)];
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (...
%!     dir_incident, [], setup);
%! 
%! %[dir_reflection.elev, dir_reflection2.elev, dir_reflection2.elev - dir_reflection.elev] % DEBUG
%! %[dir_reflection.azim, dir_reflection2.azim, dir_reflection2.azim - dir_reflection.azim] % DEBUG
%! %[pos_reflection.cart; pos_reflection2.cart; pos_reflection2.cart - pos_reflection.cart]  % DEBUG
%! %[delay, delay2, delay2 - delay]  % DEBUG
%! %azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true)
%! 
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -nthroot(eps(),3))
%! myassert(azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true) < nthroot(eps(),3))
%! myassert(dir_reflection.elev, dir_reflection2.elev, -nthroot(eps(),3))
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -nthroot(eps(),3))
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), -100*eps)
%! myassert(norm(pos_reflection2.cart(1:2)), delayb * sind(elev_sfc_rise), -100*eps)
%! myassert(delay, delay2, -nthroot(eps(),3))

%%
%!test
%! % tilted surface, incident signal at 45 degrees w.r.t. surface, forward.
%! elev_sfc_rise = randint(0, 45);
%! azim_sfc_rise = randint(0,360);
%! slope = elev_sfc_rise;
%! aspect = azimuth_range_positive(azim_sfc_rise + 180);
%! setup = mysetup (slope, aspect);
%! 
%! dir_incident.elev = elev_sfc_rise + 45;
%! dir_incident.azim = azim_sfc_rise;
%! 
%! dir_reflection.elev = -(45 - elev_sfc_rise);
%! dir_reflection.azim =  dir_incident.azim;
%! delayb = height * cosd(elev_sfc_rise);
%! delay = sqrt(2) * delayb;
%! pos_reflection.cart = [NaN, NaN, height + delay * sind(dir_reflection.elev)];
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incident, [], setup);
%! 
%! %dir_reflection.elev, dir_reflection2.elev, dir_reflection2.elev - dir_reflection.elev, fprintf('\n')  % DEBUG
%! %dir_reflection.azim, dir_reflection2.azim, dir_reflection2.azim - dir_reflection.azim, fprintf('\n')  % DEBUG
%! %pos_reflection.cart, pos_reflection2.cart, pos_reflection2.cart - pos_reflection.cart, fprintf('\n')  % DEBUG
%! %delay, delay2, delay2 - delay, fprintf('\n')   % DEBUG
%! 
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -nthroot(eps(),3))
%! myassert(azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true) < nthroot(eps(),3))
%! myassert(dir_reflection.elev, dir_reflection2.elev, -nthroot(eps(),3))
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -nthroot(eps(),3))
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), -100*eps)
%! myassert(norm(pos_reflection2.cart(1:2)), delay * cosd(dir_reflection.elev), -100*eps)
%! myassert(delay, delay2, -nthroot(eps(),3))

%%
%!test
%! % tilted surface, incident signal at 45 degrees w.r.t. surface, backward.
%! elev_sfc_rise = randint(0, 45);
%! azim_sfc_rise = randint(0,360);
%! slope = elev_sfc_rise;
%! aspect = azimuth_range_positive(azim_sfc_rise + 180);
%! setup = mysetup (slope, aspect);
%! 
%! dir_incident.elev = 180 - (elev_sfc_rise + 45 + 90);
%! dir_incident.azim = aspect;
%! 
%! dir_reflection.elev = dir_incident.elev - 90;
%! dir_reflection.azim = dir_incident.azim;
%! delayb = height * cosd(elev_sfc_rise);
%! delay = sqrt(2) * delayb;
%! pos_reflection.cart = [NaN, NaN, height + delay * sind(dir_reflection.elev)];
%! 
%! setup.sfc.optimizeit = false;
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (...
%!     dir_incident, [], setup);
%! 
%! %dir_reflection.elev, dir_reflection2.elev, dir_reflection2.elev - dir_reflection.elev, fprintf('\n')  % DEBUG
%! %dir_reflection.azim, dir_reflection2.azim, dir_reflection2.azim - dir_reflection.azim, fprintf('\n')  % DEBUG
%! %pos_reflection.cart, pos_reflection2.cart, pos_reflection2.cart - pos_reflection.cart, fprintf('\n')  % DEBUG
%! %delay, delay2, delay2 - delay, fprintf('\n')   % DEBUG
%! 
%! %myassert(cell2mat(struct2cell(dir_reflection)), cell2mat(struct2cell(dir_reflection2)), -nthroot(eps(),3))
%! myassert(azimuth_diff(dir_reflection.azim, dir_reflection2.azim, true) < nthroot(eps(),3))
%! myassert(dir_reflection.elev, dir_reflection2.elev, -nthroot(eps(),3))
%! %myassert(pos_reflection.cart, pos_reflection2.cart, -nthroot(eps(),3))
%! myassert(pos_reflection.cart(3), pos_reflection2.cart(3), -100*eps)
%! myassert(norm(pos_reflection2.cart(1:2)), delay * cosd(dir_reflection.elev), -100*eps)
%! myassert(delay, delay2, -nthroot(eps(),3))
%! %error('stop!')  % DEBUG
