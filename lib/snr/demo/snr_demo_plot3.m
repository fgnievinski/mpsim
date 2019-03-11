function snr_demo_plot3 (result3, result2, result1, label)
  figure
    hold on
    plotsin(result3.sat.elev, result3.snr_db, 'x-b')
    plotsin(result2.sat.elev, result2.snr_db, '.-r')
    plotsin(result1.sat.elev, result1.snr_db, 'o-g')
    xlimsin(result1.sat.elev([1 end]))
    xlabel('Elevation angle (degrees)')
    ylabel('SNR (dB)')
    grid on
    legend(label, 'Location','SouthEast')
    %fixfig()
end

