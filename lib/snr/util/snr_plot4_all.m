function snr_plot4_all (nmea, elev_lim, style, savedir, pauseit, signed)
  if (nargin < 2),  elev_lim = [];  end
  if (nargin < 3),  style = [];  end
  if (nargin < 4),  savedir = [];  end
  if (nargin < 5) || isempty(pauseit),  pauseit = true;  end
  if (nargin < 6) || isempty(signed),  signed = false;  end
  if isfieldempty(nmea, 'info', 'doy')
    nmea.info.doy = mydatedoy(nmea.info.epoch);
  end
  if ~isempty(savedir) && ~exist(savedir, 'dir')
    error('Output directory "%s" does not exist.', char(savedir));
  end
  for i=1:numel(nmea.info.prn_unique)
    prn = nmea.info.prn_unique(i);
    
    if isempty(signed)
      snr_plot4_all_aux (prn, nmea, elev_lim, style, savedir, pauseit, []);
    else
      snr_plot4_all_aux (prn, nmea, elev_lim, style, savedir, pauseit, -1);
      snr_plot4_all_aux (prn, nmea, elev_lim, style, savedir, pauseit, +1);
    end    
  end
end

%%
function snr_plot4_all_aux (prn, nmea, elev_lim, style, savedir, pauseit, thesign)
    fh=figure();
    maximize(fh)
    zoom(fh);
    
    if isempty(thesign)
      status = snr_plot4 (nmea, prn, elev_lim, style);
      filename = sprintf('PRN%02.0f.png', prn);
    else
      status = snr_plot4 (nmea, prn, elev_lim, style, thesign);
      %filename = sprintf('PRN%+02.0f.png', prn*thesign);
      filename = sprintf('PRN%02.0f%c.png', prn, getel(sprintf('%+f', thesign), 1));
    end
    
    if ~status
      close(fh);
      return;
    end

    if ~isempty(savedir)
      saveas(fh, fullfile(savedir, filename));
    end
    
    if status && pauseit
      disp('Paused; hit Enter to continue or Ctrl+C to stop.');
      pause();
    end
    
    if ishghandle(fh)
      close(fh)
    end
end
