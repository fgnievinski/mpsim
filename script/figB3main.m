% SNR simulations for the same carrier frequency (L2) and receiving antenna
% (TRM29659.00) but different code modulations.
% 
% Main plot in Fig. 3 in Nievinski, F.G. and Larson, K.M., "An open source
% GPS multipath simulator in Matlab/Octave", GPS Solut. (in press)

sett0 = snr_settings_paper();

%%
sett_sc = sett0;
setup_sc = snr_setup(sett_sc);
result_sc = snr_fwd(setup_sc);

%%
sett_s2 = sett0;
sett_s2.opt.code_name = 'P(Y)';
sett_s2.opt.disable_tracking_loss = false;
sett_s2.opt.extrap_tracking_loss = true;
setup_s2 = snr_setup(sett_s2);
result_s2 = snr_fwd(setup_s2);

%%
elev_lim_plot = [1 sett0.sat.elev_lim(2)];
myminmaxaux  = @(minmax, result) minmax(result.snr_db(result.sat.elev > elev_lim_plot(1)));
myminmax = @(minmax) minmax(myminmaxaux(minmax, result_sc), myminmaxaux(minmax, result_s2));

figure
  if sett0.opt.max_plot,  maximize();  end
  hold on
  myplot(setup_sc.sat.elev, result_sc.snr_db, '-b', 'LineWidth',2);
  myplot(setup_s2.sat.elev, result_s2.snr_db, '-r', 'LineWidth',4);
  ylim([myminmax(@min), myminmax(@max)])
  yl = ylim();  ylim(yl+[-1,+1]*0.1/2*diff(yl))
  legend({'L2C','P(Y)'}, 'Location','NorthWest')
  grid on
  xlabel('Elevation angle (degrees)')
  ylabel('SNR (dB)')
  mysaveas('figB3main')
