function status = snr_plot4 (gps, prn, elev_lim, style, thesign)
  if (nargin < 3) || isempty(elev_lim),  elev_lim = [1 15];  end
  if (nargin < 4) || isempty(style),  style = {'.-k', 'ok'};  end
  if (nargin < 5),  thesign = [];  end
  if ~iscell(style),  style = {style};  end
  if isscalar(style),  style = [style style];  end
  if isfieldempty(gps, 'info', 'doy')
    gps.info.doy = mydatedoy(gps.info.epoch);
  end
  
  idx = (gps.info.status == 'A') & (gps.info.prn == prn);
  doy = gps.info.doy(idx);
  snr = gps.data(idx);
  elev = gps.info.elev(idx);
  azim = gps.info.azim(idx);
  
  if ~isempty(thesign)
    time = gps.info.epoch(idx);
    erate = gradient(elev, time);
    idx2 = (sign(erate) ~= thesign);
    idx(idx2) = [];
    doy(idx2) = [];
    snr(idx2) = [];
    elev(idx2) = [];
    azim(idx2) = [];
  end
  %status = any(idx);
  status = any(idx) && any(~isnan(snr));
  
  s1 = style{1};
  s2 = style{2};
  hs = subplot(4,2,[1 3]);
    plot(doy, snr, s1)
    ylabel('SNR (dB)')
    %set(gca(), 'XAxisLocation','top')
    grid on
    title(sprintf('Sat. PRN %02d', prn))
  he = subplot(4,2,5);
    plot(doy, elev, s2)
    ylabel('Elev. (deg.)')
    ylim([0 090])
    set(gca(), 'YTick',0:15:090)
    grid on
  ha = subplot(4,2,7);
    plot(doy, azim, s2)
    ylabel('Azim. (deg.)')
    ylim([0 360])
    set(gca(), 'YTick',0:90:360)
    grid on
    xlabel('Epoch (DOY)')    
  hr = subplot(4,2,[2 4]);
    hsto = plotsin(elev, snr, s1);
    xlimsin(elev_lim)
    ylabel('SNR (dB)')
    grid on
    set(gca(), 'YAxisLocation','right')
    set(gca(), 'XAxisLocation','top')
  hy = subplot(4,2,[6 8]);
    polar(0, 1, '.w');  hold on;  % set max axes
    hsky = polar(deg2rad(azim), cosd(elev), '.k');
    view(90,-90)
  hl = [hs he ha];
  linkaxes(hl, 'x')
  
  get_doy_idx = @(doy_lim) (doy_lim(1) <= doy & doy <= doy_lim(2));
  %tmp = @(varargin) disp('hw!')
  tmp1 = @(varargin) set(hsto, ...
    'XData',sind(elev(get_doy_idx(xlim(hs)))), ...
    'YData',snr(get_doy_idx(xlim(hs))) ...
  );
  tmp2 = @(varargin) set(hsky, ...  % set XData/YData for skyplot.
    'XData',cosd(elev(get_doy_idx(xlim(hs)))).*cosd(azim(get_doy_idx(xlim(hs)))), ...
    'YData',cosd(elev(get_doy_idx(xlim(hs)))).*sind(azim(get_doy_idx(xlim(hs))))  ...
  );
  %tmp3 = tmp1;
  tmp3 = @(varargin) [tmp1(), tmp2()];
  el = addlistener(hs,'XLim','PostSet',tmp3);
  set(gcf(), 'DeleteFcn',@(varargin)delete(el))
  %break
end
