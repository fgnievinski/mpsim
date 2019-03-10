% Multipath signature in GPS SNR, carrier phase, and code pseudorange
% observables for a typical setup. The reflecting surface is horizontal,
% made up of soil with mediumlevel moisture and negligible roughness. A
% choke-ring antenna installed upright on a 1.5-m-tall monument is
% postulated. The rigorous solution is shown in blue, approximations in
% red; for code pseudorange, the thick (thin) red line corresponds to
% small-delay (small-delay and small-power) approximation. Please notice
% the difference in scales between code (cm) and phase (mm)
% 
% Fig. 1 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper ();

sett1 = sett0;
setup1 = snr_setup(sett1);
result1 = snr_fwd(setup1);

sett2 = sett0;
sett2.opt.phase_approx_small_power = true;
sett2.opt.dsss.approx_small_delay = true;
sett2.opt.dsss.approx_small_power = false;
setup2 = snr_setup(sett2);
result2 = snr_fwd(setup2);

sett3 = sett0;
sett3.opt.dsss.approx_small_delay = true;
sett3.opt.dsss.approx_small_power = true;
setup3 = snr_setup(sett3);
result3 = snr_fwd(setup3);

%%
elev_lim_myplot = [1 sett0.sat.elev_lim(2)];
myylim = @(y) ylim([...
  min(y(result1.sat.elev > elev_lim_myplot(1))), ...
  max(y(result1.sat.elev < elev_lim_myplot(2)))  ...
]);

figure
if sett0.opt.max_plot,  maximize();  end
mysubplot(3,1,1)
  hold on
  myplot(result1.sat.elev, result1.snr_db, '-b', 'LineWidth',2)
  ylabel('SNR (dB)')
  set(gca(), 'XTickLabel',[])
  myylim(result1.snr_db);
  if ~is_octave(),  set(gca(), 'YTickLabel',strcats('  ', get(gca(), 'YTickLabel')));  end  % align y labels.
mysubplot(3,1,2)
  hold on
  myplot(result1.sat.elev, result1.carrier_error*1e3, '-b', 'LineWidth',2)
  myplot(result1.sat.elev, result2.carrier_error*1e3, '-r', 'LineWidth',1)
  ylabel('Phase (mm)')
  set(gca(), 'XTickLabel',[])
  myylim(result1.carrier_error*1e3);
mysubplot(3,1,3)
  hold on
  myplot(result1.sat.elev, result2.code_error*1e2, '-r', 'LineWidth',3)
  myplot(result1.sat.elev, result1.code_error*1e2, '-b', 'LineWidth',2)
  myplot(result1.sat.elev, result3.code_error*1e2, '-r', 'LineWidth',1)
  ylabel('Code (cm)')
  xlabel('Elevation angle (degrees)')
  myylim(result1.code_error*1e2);
for i=1:3
  mysubplot(3,1,i)
  grid on
  yl = ylim();  ylim(yl+[-1,+1]*0.1/2*diff(yl))
end
mysaveas('figA1')
