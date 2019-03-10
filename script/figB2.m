% Results for different antenna orientations and satellite alignment
% (coinciding with the antenna boresight or varying ±90° in azimuth)
% 
% Fig. 2 in Nievinski, F.G. and Larson, K.M., "An open source GPS multipath
% simulator in Matlab/Octave", GPS Solut. (in press)

%%
sett0 = snr_settings();
sett0.sat.elev_lim = [0 90];
sett1 = sett0;  sett1.ant.slope = 'upright';
sett2 = sett1;  sett2.ant.slope = 'tipped';
sett3 = sett2;  sett3.sat.azim_lim = [-90 90];

setup0 = snr_setup (sett0);
setup1 = snr_resetup (sett1, setup0);
setup2 = snr_resetup (sett2, setup1);
setup3 = snr_resetup (sett3, setup2);

result1 = snr_fwd (setup1);
result2 = snr_fwd (setup2);
result3 = snr_fwd (setup3);

label1 = 'Upright';
label2 = sprintf('Tipped\nant. aspect = sat. azim.');
label3 = sprintf('Tipped\nant. aspect = 0\nsat. azim. \\in [-90, +90]');

snr_demo_plot3 (result3, result2, result1, {label3 label2 label1})
  set_xtick_label_asind2 ([], 5)

mysaveas('figB2')
