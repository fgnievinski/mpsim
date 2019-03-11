function snr_demo_plot_prof (setup)

figure
subplot(1,2,1)
  plot(real(setup.sfc.permittivity_middle), setup.sfc.depth_midpoint*1e2, 'o-k', 'LineWidth',2)
  set(gca, 'YDir','reverse')
  xlabel('Real perm.')
  ylabel('Depth (cm)')
  grid
subplot(1,2,2)
  plot(imag(setup.sfc.permittivity_middle), setup.sfc.depth_midpoint*1e2, 'o-k', 'LineWidth',2)
  set(gca, 'YDir','reverse')
  set(gca, 'YAxisLocation','right')
  xlabel('Imag. perm.')  
  ylabel('Depth (cm)')
  grid
  
