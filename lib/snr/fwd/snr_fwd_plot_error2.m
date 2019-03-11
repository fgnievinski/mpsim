function snr_fwd_plot_error2 (result1, result2, max_plot, myplot)
  %myplot_default = @plot;
  myplot_default = @plotsin;
  if (nargin < 3) || isempty(max_plot),  max_plot = false;  end
  if (nargin < 4) || isempty(myplot),  myplot = myplot_default;  end
  %myplot = @plotsin;  % DEBUG

  myxlim = @xlim;
  if isequal(myplot, @plotsin),  myxlim = @xlimsin;  end

  figure
  if max_plot,  maximize();  end
  subplot(3,1,1)
    hold on
    myplot(result1.sat.elev, result1.snr_db, '-b', 'LineWidth',2)
    myplot(result2.sat.elev, result2.snr_db, '-r', 'LineWidth',2)
    myxlim(result1.sat.elev([1 end]))
    %xlabel('Elevation angle (degrees)')
    set(gca(), 'XTickLabel',[])
    ylabel('SNR (dB)')
    grid on
  subplot(3,1,2)
    hold on
    myplot(result1.sat.elev, result1.carrier_error*1e3, 'ob', 'LineWidth',2)
    myplot(result2.sat.elev, result2.carrier_error*1e3, '-r', 'LineWidth',2)
    myxlim(result1.sat.elev([1 end]))
    set(gca(), 'XTickLabel',[])
    %xlabel('Elevation angle (degrees)')
    ylabel('Phase (mm)')
    grid on
  subplot(3,1,3)
    hold on
    myplot(result1.sat.elev, result1.code_error*1e2, '-b', 'LineWidth',2)
    myplot(result2.sat.elev, result2.code_error*1e2, '-r', 'LineWidth',2)
    myxlim(result1.sat.elev([1 end]))
    xlabel('Elevation angle (degrees)')
    ylabel('Code (cm)')
    grid on

end
