function snr_plot4_all (nmea, elev_lim)
  if (nargin < 2) || isempty(elev_lim),  elev_lim = [1 15];  end
  if isfieldempty(nmea, 'info', 'doy')
    nmea.info.doy = mydatedoy(nmea.info.epoch);
  end
  for i=1:numel(nmea.info.prn_unique)
    prn = nmea.info.prn_unique(i);
    
    figure
    maximize()
    snr_plot4 (nmea, prn, elev_lim)
    pause()
    close(gcf())
  end
end
