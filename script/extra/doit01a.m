result = snr_fwd();

figure
if sett0.opt.max_plot,  maximize();  end
subplot(3,1,1)
  plot(result.sat.elev, result.snr_db, '-k', 'LineWidth',2)
  ylabel('SNR (dB)')
subplot(3,1,2)
  plot(result.sat.elev, result.carrier_error*1e3, '-k', 'LineWidth',2)
  ylabel('Phase (mm)')
subplot(3,1,3)
  plot(result.sat.elev, result.code_error*1e2, '-k', 'LineWidth',2)
  ylabel('Code (cm)')
  xlabel('Elevation angle (degrees)')
for i=1:3
  subplot(3,1,i)
  grid on
  axis tight
  yl = ylim();  ylim(yl+[-1,+1]*0.1/2*diff(yl))
end
for i=1:2
  subplot(3,1,i)
  xlabel([])
  set(gca, 'XTickLabel',[])
end
