function [height_ant_perp, sat_graz, delay, sing] = snr_fwd_geometry_reflection_tilted_simple (...
height_ant_vert, sat_elev, sat_azim, sfc_slope, sfc_aspect)
% function [height_ant_perp, sat_graz, delay, doppler] = snr_fwd_geometry_reflection_tilted_simple (...
% height_ant_vert, sat_elev, sat_azim, sfc_slope, sfc_aspect, velocity_vert, sat_elev_rate, sat_azim_rate)
    height_ant_perp = height_ant_vert .* cosd(sfc_slope);
    %height_ant_perp = height_ant_vert ./ cosd(sfc_slope);  % WRONG!
    if (nargout < 2),  return;  end
    
    sat_dir = sph2cart_local([sat_elev(:) sat_azim(:)]);
    sfc_normal = slopeaspect2sfcnrml (sfc_slope, sfc_aspect);

    [sat_graz, sat_incid, cosi] = convert_dir_local2sfc_grazing (...
        sat_dir, sfc_normal); %#ok<ASGLU>
    if (nargout < 3),  return;  end

    sing = cosi;
      %max(abs(sing - sind(sat_graz)))  % DEBUG    
    delay = 2*height_ant_perp.*sing;
    %TODO: Doppler:
    % - convert velocity_vert to velocity_perp;
    % - convert sat_elev_rate/sat_azim_rate to sat_graz_rate;
    % - apply formula analogous to horizontal suface.
end

%!test
%! n = 20;
%! height = 2;
%! slope = randint(0, 90);
%! aspect = randint(0, 360);
%! elev = randint(0, 90, n, 1);
%! azim = randint(0, 360, n, 1);
%! %azim(:) = aspect;  % DEBUG
%! %azim(:) = azimuth_range_positive(aspect+180);  % DEBUG
%! sfc_pos0 = [0 0 0];
%! 
%! sett = snr_settings();
%! sett.ref.ignore_vec_apc_arp = true;
%! sett.ref.height_ant = height;
%! sett.sfc.fnc_snr_setup_sfc_geometry = @snr_setup_sfc_geometry_tilted;
%! sett.sfc.slope  = slope;
%! sett.sfc.aspect = aspect;
%! setup = snr_setup(sett);
%! myassert(setup.ref.pos_ant, [0 0 2])
%! sfc = setup.sfc;
%! 
%! dir_incid = struct('elev',elev, 'azim',azim);
%! [dir_reflection2, pos_reflection2, delay2] = ...
%!     snr_fwd_geometry_reflection_tilted (dir_incid, [], setup);
%! %dir_reflection3 = snr_fwd_direction_local2sfc_grazing (dir_reflection2, sfc.dir_nrml.cart);  % WRONG!
%! dir_incid3 = snr_fwd_direction_local2sfc_grazing (dir_incid, sfc.dir_nrml.cart);
%! 
%! [height_perp, graz, delay] = snr_fwd_geometry_reflection_tilted_simple (...
%!     height, elev, azim, slope, aspect);
%! 
%! %[slope, aspect]
%! %[elev, azim]
%! %[graz, dir_incid3.graz, dir_incid3.graz-graz]
%! %[delay, delay2, delay2-delay]
%! %[height_perp, sfc.dist_ant_sfc_perp]
%! 
%! myassert(height_perp, sfc.dist_ant_sfc_perp, -sqrt(eps()))
%! myassert(graz, dir_incid3.graz, -sqrt(eps()))
%! myassert(delay, delay2, -sqrt(eps()))
