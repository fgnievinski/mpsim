function snr_demo_plot_diff (result, result0)
figure
  hold on
  plotsin(result.sat.elev, result.snr_db - result0.snr_db, '-k', 'MarkerSize',10)
  xlimsin(result.sat.elev([1 end]))
  xlabel('Elevation angle (degrees)')
  ylabel('SNR (dB)')
  grid on
  legend({'Difference'}, 'Location','SouthEast')
  %fixfig()

