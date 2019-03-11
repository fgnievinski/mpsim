function snr_fwd_plot_error (result, max_plot, myplot)
  %myplot_default = @plot;
  myplot_default = @plotsin;
  if (nargin < 2) || isempty(max_plot),  max_plot = false;  end
  if (nargin < 3) || isempty(myplot),  myplot = myplot_default;  end

  %myplot = @plotsin;  % DEBUG

  myxlim = @xlim;
  if isequal(myplot, @plotsin),  myxlim = @xlimsin;  end

  figure
  if max_plot,  maximize();  end
  subplot(3,1,1)
    hold on
    myplot(result.sat.elev, result.snr_db, '-k', 'LineWidth',2)
    myxlim(result.sat.elev([1 end]))
    %xlabel('Elevation angle (degrees)')
    set(gca(), 'XTickLabel',[])
    ylabel('SNR (dB)')
    grid on
  subplot(3,1,2)
    hold on
    myplot(result.sat.elev, result.carrier_error*1e3, '-k', 'LineWidth',2)
    myxlim(result.sat.elev([1 end]))
    set(gca(), 'XTickLabel',[])
    %xlabel('Elevation angle (degrees)')
    ylabel('Phase (mm)')
    grid on
  subplot(3,1,3)
    myplot(result.sat.elev, result.code_error*1e2, '-k', 'LineWidth',2)
    myxlim(result.sat.elev([1 end]))
    xlabel('Elevation angle (degrees)')
    ylabel('Code (cm)')
    grid on

end
