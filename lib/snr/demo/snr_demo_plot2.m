function snr_demo_plot2 (result, result0, label)
  if (nargin < 3),  label = {'Modified', 'Defaults'};  end
  figure
    hold on
    plotsin(result.sat.elev, result.snr_db, 'o-b', 'MarkerSize',10)
    plotsin(result0.sat.elev, result0.snr_db, '.-r')
    xlimsin(result0.sat.elev([1 end]))
    xlabel('Elevation angle (degrees)')
    ylabel('SNR (dB)')
    grid on
    legend(label, 'Location','SouthEast')
    %fixfig()
end

