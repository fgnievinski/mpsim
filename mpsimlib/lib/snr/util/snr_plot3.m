function snr_plot3 (gps, prn, elev_lim)
  idx = (gps.info.status == 'A') & (gps.info.prn == prn);
  doy = gps.info.doy(idx);
  snr = gps.data(idx);
  elev = gps.info.elev(idx);
  azim = gps.info.azim(idx);
  s = '.-k';
  subplot(3,2,1)
  hs = subplot(3,2,1); plot(doy,  snr, s)
  he = subplot(3,2,3); plot(doy,  elev, s)
  ha = subplot(3,2,5); plot(doy,  azim, s)
  get_doy_idx = @(doy_lim) (doy_lim(1) <= doy & doy <= doy_lim(2));
  hr = subplot(3,2,[2 4 6]); hsto = plotsin(elev, snr, s);  xlimsin(elev_lim);
  grid on
  hl = [hs he ha];
  linkaxes(hl, 'x')
  tmp = @(varargin) set(hsto, ...
    'XData',sind(elev(get_doy_idx(xlim(hs)))), ...
    'YData',snr(get_doy_idx(xlim(hs))) ...
  );
  %tmp = @(varargin) disp('hw!')
  addlistener(hs,'XLim','PostSet',tmp);
  title(hr, sprintf('Sat. PRN %02d', i))
  %break
end
