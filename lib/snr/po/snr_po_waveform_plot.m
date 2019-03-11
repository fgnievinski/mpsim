function snr_po_waveform_plot (waveform, sett)
  if (nargin < 3),  sett = [];  end
  if isempty(sett),  sett = struct();  end
  if isfieldempty(sett, 'raw_decim_factor'),  sett.raw_decim_factor = 1;  end
  if isfieldempty(sett, 'detrend_snr'),  sett.detrend_snr = true;  end
  if isfieldempty(sett, 'detrend_delay'),  sett.detrend_delay = false;  end
  if isfieldempty(sett, 'fresnel_zone_max'),  sett.fresnel_zone_max = 15;  end
  snr_int = mean(waveform.int.snr_db);
  sp_delay = min(waveform.raw.delay);
  if sett.detrend_snr,  snr_base = snr_int;  suffix = ' change';  else  snr_base = 0;  suffix = '';  end
  if sett.detrend_delay,  delay_base = sp_delay;  prefix = 'Relative ';  else  delay_base = 0;  prefix = '';  end
  
  fz_factor = (1:sett.fresnel_zone_max)';
  fz_delay = fresnel2delay (fz_factor, waveform.wavelength) + sp_delay;

  lab = {};  han = [];
  %lab_elem = 'Elemental responses';
  lab_elem = sprintf('Elemental responses\n(times integrated count)');
  
  figure
  hold on
  
  ind = 1:sett.raw_decim_factor:numel(waveform.raw.delay);
  h = scatter(waveform.raw.delay(ind), waveform.raw.snr_db(ind)-snr_base, ...
      3.5^2, waveform.raw.dist(ind), 'filled');
  %h = plot(waveform.raw.delay(ind), waveform.raw.snr_db(ind)-snr_base, '.b');  % DEBUG
   han(end+1) = h(1);  lab{end+1} = lab_elem;
  
  h = plot(waveform.int.delay - delay_base, waveform.int.snr_db - snr_base, '-k', ...
    'LineWidth',2, 'Color','r');%[1 1 1]*0.25);
    han(end+1) = h(1);  lab{end+1} = 'Integrated response';

  %ylim([-1,+1]*mean(abs(ylim())))
  ylim([-1,+1]*min(abs(ylim())))
  
  co2 = 'b';
  h = vline(fz_delay(2:end) - delay_base,  {'-b', 'LineWidth',0.25, 'Color',co2});
    han(end+1) = h(1);  lab{end+1} = 'Other FZ limits';

  h = vline(sp_delay - delay_base, {'-b', 'LineWidth',1.5, 'Color',co2});
    han(end+1) = h(1);  lab{end+1} = 'Specular point';

  h = vline(fz_delay(1) - delay_base,  {'--b', 'LineWidth',1.5, 'Color',co2});
    han(end+1) = h(1);  lab{end+1} = 'FFZ limit';
  
  xlim([min(xlim()), max(waveform.int.delay)-delay_base])
  hline(snr_int - snr_base, {'--k', 'LineWidth',1.5})
  grid on
  xlabel(capitalize([prefix 'bistatic delay (m)']))
  ylabel(['SNR' suffix ' (dB)'])
  
  set(gca(), 'CLim',[0 max(get(gca(), 'CLim'))])
  cm = flipud(gray());
  prc = 15;
  cm = cm(round(end*prc/100):end,:);  % discard first prc% of whites.
  colormap(cm)
  h = colorbar();
    title(h, 'Distance (m)')
    ylim(h, [0 max(ylim(h))])

  lab2 = {...
    'Integrated response'
    lab_elem
    'Specular point'
    'FFZ limit'
    'Other FZ limits'
  };
  [idx,loc] = ismember(lab2, lab);
    assert(all(idx))
    myassert(lab2, lab(loc)')
  han2 = han(loc);
  
  %hl = legend(han2, lab2, 'Location','SouthEast');
  
  hl = legend(han2(1:2), lab2(1:2), 'Location','NorthEast');
    %'EdgeColor',[1 1 1], 'Box','off');
  hl2 = copyobj(hl, gcf());
  hl3 = legend(han2(3:end), lab2(3:end), 'Location','SouthEast');
    %'EdgeColor',[1 1 1], 'Box','off');
end
