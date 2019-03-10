%%
sett = snr_settings_paper();
sett.ant.load_redundant = true;
%sett.ant.load_redundant = false;
setup = snr_setup(sett);

%%
if is_octave()
  error('Sorry, antenna plotting functions not supported in Octave.')
end
  
%%
antenna_gain_plot3 (setup.ant.gain.rhcp, setup.ant.gain.lhcp)
title('')
%mysaveas('22a')

%%
antenna_gain_plot5 (setup.ant.gain.rhcp, setup.ant.gain.lhcp, 1.1)
title('')
%mysaveas('22b')

%%
antenna_gain_plot6 (setup.ant.gain.lhcp)
title('')
set(gcf(), 'Color','w', 'InvertHardCopy','off')
%mysaveas('22c', {'png','epsc2'}),  mysaveas([], 'epsc2')

%%
return
antenna_gain_plot5 (setup.ant.gain.rhcp, setup.ant.gain.lhcp, 1)
antenna_gain_plot5 (setup.ant.gain.rhcp, setup.ant.gain.lhcp, 2)
antenna_gain_plot3 (setup.ant.gain.rhcp, setup.ant.gain.lhcp)

%%
return
antenna_gain_plot2 (setup.ant.gain.rhcp, setup.ant.gain.lhcp)

antenna_gain_plot (setup.ant.gain.rhcp)
antenna_gain_plot (setup.ant.gain.lhcp)
