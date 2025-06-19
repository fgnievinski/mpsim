function [along, across, slope, aspect, azim] = slopeaspect2alongacross (slope, aspect, azim)
    [slope, aspect, azim, size_original] = slopeaspectazim_expand (slope, aspect, azim);
    sfc_nrml_dir = slopeaspect2sfcnrml (slope, aspect);
    sfc_nrml_dir = -sfc_nrml_dir;  % DEBUG
    
    % azimuth refers to the satellite direct or line-of-sight direction, 
    % not to its reflection on the tilted surface, which is a complication.
    sat_azim_val = azim;
    sat_azim_dir = sph2cart_local([zeros(size(sat_azim_val)), sat_azim_val]);
    up_dir = [0 0 1];

    along  = 90 - acosd(dot_all(sfc_nrml_dir, sat_azim_dir));
    across = 90 - acosd(dot_all(sfc_nrml_dir, cross_all(sat_azim_dir, up_dir)));

    % 10-deg slope and 0-deg aspect yield -10-deg angle along track at 0-deg azimuth:
    %along = -along;  
    
    along  = reshape(along,  size_original);
    across = reshape(across, size_original);
    slope  = reshape(slope,  size_original);
    aspect = reshape(aspect, size_original);
    azim   = reshape(azim,   size_original);
end

%!test
%! %%
%! slope0 = 10;
%! aspect0 = 0;
%! temp = [...
%!     0   -10 0
%!     180 +10 0
%!     90  0   -10
%!     270 0   +10
%! ];
%! [azim, along0, across0] = deal2(temp);
%! 
%! aspect0 = 40;
%! %aspect0 = randint(0, 360);
%! azim = azim + aspect0;
%! 
%! slope0 = repmat(slope0, size(azim));
%! aspect0 = repmat(aspect0, size(azim));
%! 
%! [along1, across1] = slopeaspect2alongacross (slope0, aspect0, azim);
%! [slope1, aspect1] = alongacross2slopeaspect (along0, across0, azim);
%! 
%! %%
%! axial = 0;
%! sfc = struct();
%! [sfc.rot, sfc.dir_nrml] = get_rotation_matrix3_local (slope0, aspect0, axial);
%! n = numel(azim);
%! dira = struct('azim',azim, 'elev',zeros(n,1));
%! dirb = struct('azim',0,    'elev',90);
%! tempa = snr_fwd_direction_local2 (n, dira, sfc.rot, sfc.dir_nrml, [], [], [], [], false);
%! tempb = snr_fwd_direction_local2 (1, dirb, sfc.rot, sfc.dir_nrml, [], [], [], [], false);
%! tempc = struct('cart',cross_all(tempa.cart, tempb.cart));
%! tempc.sph = cart2sph_local(tempc.cart);
%! along2  = -tempa.sph(:,1);
%! across2 = -tempc.sph(:,1);
%! 
%! %%
%! %clc
%! %temp = [azim, along0, along1, along2, along1-along0, along2-along0];
%! %cprintf(temp, '-Lc',{'azim', 'along0', 'along1', 'along2', 'along1-along0', 'along2-along0'}, '-n','%g')
%! %temp = [azim, across0, across1, across2, across1-across0, across2-across0];
%! %cprintf(temp, '-Lc',{'azim', 'across0', 'across1', 'across2', 'across1-across0', 'across2-across0'}, '-n','%.1g')
%! 
%! %%
%! %clc
%! %temp = [azim, slope0, slope1, slope1-slope0];
%! %cprintf(temp, '-Lc',{'azim', 'slope0', 'slope1', 'slope1-slope0'}, '-n','%g')
%! %temp = [azim, aspect0, aspect1, aspect1-aspect0];
%! %cprintf(temp, '-Lc',{'azim', 'aspect0', 'aspect1', 'aspect1-aspect0'}, '-n','%g')
%!  
%! %%
%! myassert( along1,  along0, -sqrt(eps()))
%! myassert( along2,  along0, -sqrt(eps()))
%! myassert(across1, across0, -sqrt(eps()))
%! myassert(across2, across0, -sqrt(eps()))
%! 
%! myassert( slope1,  slope0, -sqrt(eps()))
%! myassert(aspect1, aspect0, -sqrt(eps()))

%!test
%! % exhaustive grid fwd/inv consistency check.
%! slope_domain = (0:5:10)';
%! aspect_domain = (-180:90:+180)';
%! [slope_grid, aspect_grid] = meshgrid(slope_domain, aspect_domain);
%! slope0  = slope_grid(:);
%! aspect0 = aspect_grid(:);
%! aspect0 = azimuth_range_positive(aspect0);
%! azim = 0;
%! [along1, across1] = slopeaspect2alongacross (slope0, aspect0, azim);
%! [slope2, aspect2] = alongacross2slopeaspect (along1, across1, azim);
%! 
%! %%
%! %clc
%! %temp = [slope0, slope2, slope2-slope0, aspect0];
%! %cprintf(temp, '-Lc',{'slope0', 'slope2', 'slope2-slope0', 'aspect0'}, '-n','%g')
%! %temp = [aspect0, aspect2, aspect2-aspect0, slope0];
%! %cprintf(temp, '-Lc',{'aspect0', 'aspect2', 'aspect2-aspect0', 'slope0'}, '-n','%g')
%!  
%! %%
%! myassert( slope2,  slope0, -sqrt(eps()))
%! idx = (slope0 ~= 0);  % aspect is undefined in this case.
%! myassert(aspect2(idx), aspect0(idx), -sqrt(eps()))

