% Effect of soil moisture on reflection polarimetric ratio for varying
% volumetric water content. The Brewster angle is found at the intersection
% with the horizontal line at 0 dB
% 
% Fig. 6 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

%%
%moist = [0.25, 0.50, 0.75]';
moist = [0.3, 0.5, 0.7]';
freq = get_gps_const('L2', 'frequency');
material = struct('name','soil', 'moisture',moist, 'type','default');
perm = get_permittivity (material, freq);

%%
sett = snr_settings_paper ();
elev_lim = sett.sat.elev_lim;
elev = linspace(elev_lim(1), elev_lim(2), sett.sat.num_obs)';

[perm2, elev2] = meshgrid(perm, elev);
[phasor_same, phasor_cross] = get_reflection_coeff (elev2, perm2);

ratio_magn = abs(phasor_cross) ./ abs(phasor_same);
ratio_db = decibel_amplitude(ratio_magn);

%%
figure 
  if sett0.opt.max_plot,  maximize();  end
  myplot(elev, ratio_db, '-', 'LineWidth',2)
  hline(0, {'--k', 'LineWidth',2})
  xlabel('Elevation angle (degrees)')
  %unit = '${\rm{V}}{\cdot}{\rm{m}}^{-1}$';
  %unit = sprintf('(%s/%s)', unit, unit);
  ylabel('Reflection polarimetric ratio (dB)')
  %axis tight
  grid on
  h=legend(num2str(moist*100, '%.0f%%'), 'Location','NorthWest');
  myxlim(elev_lim)
  ylim([-1 +1]*50)
  mysaveas('figA6')
