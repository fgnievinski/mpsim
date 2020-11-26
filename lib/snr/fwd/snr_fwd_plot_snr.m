function snr_fwd_plot_snr (result, max_plot, myplot)
  %myplot_default = @plot;
  myplot_default = @plotsin;
  if (nargin < 2) || isempty(max_plot),  max_plot = false;  end
  if (nargin < 3) || isempty(myplot),  myplot = myplot_default;  end

  %myplot = @plotsin;  % DEBUG

  myxlim = @xlim;
  if isequal(myplot, @plotsin),  myxlim = @xlimsin;  end

  figure
  if max_plot,  maximize();  end
    hold on
    myplot(result.sat.elev, result.snr_db, '-k', 'LineWidth',2)
    myxlim(result.sat.elev([1 end]))
    xlabel('Elevation angle (degrees)')
    ylabel('SNR (dB)')
    grid on

end
