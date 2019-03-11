function [dir2, optimizeit, economic] = snr_fwd_direction_local2 (...
n, dir_local, rot, sfc_nrml, ...
aspect, slope, axial, optimizeit, economic)
    if (nargin < 4),  sfc_nrml = [];  economic = false;  end
    if (nargin < 5) || isempty(aspect),  aspect = NaN;  end
    if (nargin < 6) || isempty(slope),   slope = NaN;  end
    if (nargin < 7) || isempty(axial),   axial = 0;     end
    if (nargin < 8) || isempty(optimizeit),  optimizeit = true;  end
    if (nargin < 9) || isempty(economic),   economic = false;  end
    %optimizeit  % DEBUG
    if optimizeit && all(aspect == 0) && all(slope == 0) && all(axial == 0) ...
    && (   isempty(sfc_nrml) ...
        || (max(norm_all(minus_all(sfc_nrml.cart, [0 0 1]))) < 10*(eps())) )
        ... %|| isequal(sfc_nrml.cart, repmat([0 0 1], [size(dir_local,1),1])) )  % WRONG!
        dir2 = dir_local;
    elseif optimizeit && all(slope == 0)
        dir2.elev = dir_local.elev;
        %dir2.azim = dir_local.azim + axial;  % WRONG!
        dir2.azim = dir_local.azim - axial;
        dir2.azim = azimuth_range_positive(dir2.azim);
    elseif economic
        dir2 = snr_fwd_direction_local2sfc_grazing (dir_local, sfc_nrml.cart);
    else
        %whos dir_local  % DEBUG
        if isfieldempty(dir_local, 'cart')
            dir_local.sph  = [dir_local.elev, dir_local.azim, ones(n,1)];
            dir_local.cart = sph2cart_local (dir_local.sph);
        end
        dir2.cart = frontal_mtimes_pt(rot, dir_local.cart);
        dir2.sph  = cart2sph_local (dir2.cart);
        dir2.elev = dir2.sph(:,1);
        dir2.azim = dir2.sph(:,2);
        dir2.azim = azimuth_range_positive(dir2.azim);
    end
end

%%
%!shared
%! n = 10;
%! dir_local.elev = linspace(-90, +90, n)';
%! %dir_local.elev = linspace(0, +90, n)';
%! dir_local.azim = linspace(0, 360, n)';
%! sett = snr_settings();
%! sett.sat.num_obs = n;
%! sett.ref.height_ant = 1.89;
%! setup = snr_setup(sett);
%! ref = setup.ref;
%! dir_up_cart = [0 0 1];
%! pos_sfc0 = [0 0 0];

%%
%!test
%! % test grazing angle in horizontal surface.
%! % snr_fwd_direction_local2 ()
%! sfc_slope = 0;
%! sfc_aspects = [0; randint(0,360)];
%! for i=1:2,  sfc_aspect = sfc_aspects(i);
%! sfc_sett = struct('slope',sfc_slope, 'aspect',sfc_aspect);
%! setup.sfc = snr_setup_sfc_geometry_tilted(ref.pos_ant, pos_sfc0, sfc_sett);
%! 
%! dir_sfc0 = dir_local;
%! setup.sfc.optimizeit = true;
%! setup.sfc.economic = false;
%! [dir_sfc1, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == true)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = false;
%! [dir_sfc2, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = true;
%! [dir_sfc3, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (...
%!   dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == true)
%! 
%! % azimuth is undetermined at zenith and nadir:
%! dir_sfc0.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! dir_sfc1.azim(abs(dir_sfc1.elev) == 90) = NaN;
%! dir_sfc2.azim(abs(dir_sfc2.elev) == 90) = NaN;
%! dir_sfc3.azim(abs(dir_sfc3.elev) == 90) = NaN;
%! 
%! %[dir_sfc0.elev, dir_sfc1.elev, dir_sfc2.elev, dir_sfc3.elev]  % DEBUG
%! %[dir_sfc0.azim, dir_sfc1.azim, dir_sfc2.azim, dir_sfc3.azim]  % DEBUG
%! 
%! myassert(dir_sfc1.elev, dir_sfc0.elev, -sqrt(eps()))
%! myassert(dir_sfc2.elev, dir_sfc0.elev, -sqrt(eps()))
%! myassert(dir_sfc3.elev, dir_sfc0.elev, -sqrt(eps()))
%! %myassert(dir_sfc2.azim, dir_sfc0.azim, -sqrt(eps()))  % UNDEFINED (for sfc_slope = 0)
%! %myassert(dir_sfc3.azim, dir_sfc1.azim, -sqrt(eps()))  % UNAVAILABLE
%! %disp('hw!')  % DEBUG
%! end  % for i=...
%! %error('stop!')  % DEBUG

%%
%!test
%! % test (modified) azimuth in nearly horizontal surface.
%! % snr_fwd_direction_local2 ()
%! %rand('seed',0)  % DEBUG
%! sfc_slope = sqrt(eps());
%! sfc_aspects = [0; randint(0,360)];
%! for i=1:2,  sfc_aspect = sfc_aspects(i);
%! sfc_sett = struct('slope',sfc_slope, 'aspect',sfc_aspect);
%! setup.sfc = snr_setup_sfc_geometry_tilted(ref.pos_ant, pos_sfc0, sfc_sett);
%! setup.sfc.slope = 0;  % cheating to allow testing of optimization.
%! 
%! dir_sfc0.elev = dir_local.elev;
%! dir_sfc0.azim = azimuth_range_positive(dir_local.azim - sfc_aspect);
%! setup.sfc.optimizeit = true;
%! setup.sfc.economic = false;
%! [dir_sfc1, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == true)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = false;
%! [dir_sfc2, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = true;
%! [dir_sfc3, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == true)
%! 
%! % azimuth is undetermined at zenith and nadir:
%! dir_sfc0.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! dir_sfc1.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! dir_sfc2.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! dir_sfc3.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! 
%! %[dir_sfc0.elev, dir_sfc1.elev, dir_sfc2.elev, dir_sfc3.elev]  % DEBUG
%! %[dir_sfc0.azim, dir_sfc1.azim, dir_sfc2.azim, dir_sfc3.azim]  % DEBUG
%! 
%! myassert(dir_sfc1.elev, dir_sfc0.elev, -1e3*sqrt(eps()))
%! myassert(dir_sfc2.elev, dir_sfc0.elev, -1e3*sqrt(eps()))
%! myassert(dir_sfc3.elev, dir_sfc0.elev, -1e3*sqrt(eps()))
%! %myassert(dir_sfc1.azim, dir_sfc0.azim, -1e3*eps())  % NOT SUPPOSED TO BE CORRECT (see cheat above)
%! myassert(dir_sfc2.azim, dir_sfc0.azim, -1e3*sqrt(eps()))
%! %myassert(dir_sfc3.azim, dir_sfc0.azim, -1e3*eps())  % UNAVAILABLE
%! %disp('hw!')  % DEBUG
%! %error('stop!')  % DEBUG
%! end  % for i=...
%! %error('stop2!')  % DEBUG

%%
%!test
%! % surface is tilted but the two dir share same azimuth (first zero then non-zero)
%! % snr_fwd_direction_local2 ()
%! %rand('seed',0)  % DEBUG
%! sfc_slope = randint(0,90);
%! sfc_aspects = [0; randint(0,360)];
%! for i=1:2,  sfc_aspect = sfc_aspects(i);
%! sfc_sett = struct('slope',sfc_slope, 'aspect',sfc_aspect);
%! setup.sfc = snr_setup_sfc_geometry_tilted(ref.pos_ant, pos_sfc0, sfc_sett);
%! 
%! dir_local.azim(:) = sfc_aspect;
%! 
%! dir_sfc0.azim = dir_local.azim - sfc_aspect;
%! dir_sfc0.elev = dir_local.elev - (setup.sfc.dir_nrml.elev - 90);
%! idx = (dir_sfc0.elev > +90);
%! dir_sfc0.elev(idx) = 180 - dir_sfc0.elev(idx);
%! dir_sfc0.azim(idx) = azimuth_range_positive(dir_sfc0.azim(idx) + 180);
%! 
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = false;
%! [dir_sfc2, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = true;
%! [dir_sfc3, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == true)
%! 
%! % azimuth is undetermined at zenith and nadir:
%! dir_sfc0.azim(abs(dir_sfc0.elev) == 90) = NaN;
%! dir_sfc2.azim(abs(dir_sfc2.elev) == 90) = NaN;
%! dir_sfc3.azim(abs(dir_sfc3.elev) == 90) = NaN;
%! 
%! %[dir_sfc0.elev, dir_sfc2.elev, dir_sfc3.elev]
%! %[dir_sfc0.azim, dir_sfc2.azim, dir_sfc3.azim]
%! %[dir_sfc0.azim - dir_sfc2.azim, dir_sfc2.azim - 360]
%! 
%! myassert(dir_sfc2.elev, dir_sfc0.elev, -sqrt(eps()))
%! myassert(dir_sfc3.elev, dir_sfc0.elev, -sqrt(eps()))
%! myassert(all(abs(azimuth_diff(dir_sfc2.azim, dir_sfc0.azim) < sqrt(eps()))))
%! %myassert(dir_sfc2.azim, dir_sfc0.azim, -sqrt(eps()))
%! %myassert(dir_sfc3.azim, dir_sfc0.azim, -1e3*eps())  % UNAVAILABLE
%! %error('stop!')  % DEBUG
%! end  % for i=...
%! %error('stop2!')  % DEBUG

%%
%!test
%! % general case
%! % snr_fwd_direction_local2 ()
%! %rand('seed',0)  % DEBUG
%! sfc_slope  = randint(0,90);
%! sfc_aspect = randint(0,360);
%! sfc_sett = struct('slope',sfc_slope, 'aspect',sfc_aspect);
%! setup.sfc = snr_setup_sfc_geometry_tilted(ref.pos_ant, pos_sfc0, sfc_sett);
%! 
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = false;
%! [dir_sfc2, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == false)
%! setup.sfc.optimizeit = false;
%! setup.sfc.economic = true;
%! [dir_sfc3, optimizeit, economic] = snr_fwd_direction_local2sfc_tilted (dir_local, setup);
%!   assert(optimizeit == false)
%!   assert(economic == true)
%! 
%! % azimuth is undetermined at zenith and nadir:
%! dir_sfc2.azim(abs(dir_sfc2.elev) == 90) = NaN;
%! dir_sfc3.azim(abs(dir_sfc3.elev) == 90) = NaN;
%! 
%! %[dir_sfc2.elev, dir_sfc3.elev, dir_sfc2.elev - dir_sfc3.elev]
%! %[dir_sfc2.azim, dir_sfc3.azim, dir_sfc2.azim - dir_sfc3.azim]
%! 
%! myassert(dir_sfc3.elev, dir_sfc2.elev, -sqrt(eps()))
%! %error('stop!')  % DEBUG

%%
%!test
%! % antenna is leveled yet rotated:
%! % snr_fwd_direction_local2()
%! %rand('seed',0)  % DEBUG
%! sett.ant.slope = 0;
%! sett.ant.aspect = 0;
%! sett.ant.axial = randint(0, 360);
%! %sett.ant.axial = 0  % DEBUG
%! setup.ant = snr_setup_ant (sett.ant, sett.opt.freq_name);
%! dir_local_original = dir_local;
%! for i=1:2
%! if (i==1)
%!     dir_local.azim(:) = sett.ant.axial;
%! else
%!     dir_local.azim = dir_local_original.azim;
%! end
%! 
%! setup.ant.optimizeit = false;
%! [dir_ant1, optimizeit] = snr_fwd_direction_local2ant (dir_local, setup);
%!   assert(optimizeit == false)
%! setup.ant.optimizeit = true;
%! [dir_ant2, optimizeit] = snr_fwd_direction_local2ant (dir_local, setup);
%!   assert(optimizeit == true)
%! 
%! % azimuth is undetermined at zenith and nadir:
%! dir_local.azim(abs(dir_local.elev) == 90) = NaN;
%!  dir_ant1.azim(abs(dir_local.elev) == 90) = NaN;
%!  dir_ant2.azim(abs(dir_local.elev) == 90) = NaN;
%! 
%! % elev is unaffected:
%! myassert(dir_ant1.elev, dir_local.elev, -sqrt(eps()))
%! myassert(dir_ant2.elev, dir_local.elev, -sqrt(eps()))
%! 
%! % azim changes:
%! temp = repmat(azimuth_range_positive(-sett.ant.axial), n, 1);  
%! temp(abs(dir_local.elev) == 90) = NaN;
%! temp1 = azimuth_range_positive(azimuth_diff(dir_ant1.azim, dir_local.azim));
%! temp2 = azimuth_range_positive(azimuth_diff(dir_ant2.azim, dir_local.azim));
%! %[dir_local.elev, dir_local.azim, dir_ant1.azim, dir_ant2.azim, temp1, temp2, temp]  % DEBUG
%! myassert(temp1, temp, -sqrt(eps()))
%! myassert(temp2, temp, -sqrt(eps()))
%! %error('stop!')  % DEBUG

