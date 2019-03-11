function waveform = snr_po_waveform (result, sett)
    if (nargin < 2),  sett = [];  end
    if isempty(sett),  sett = struct();  end
    waveform = struct();
    waveform.wavelength = result.info.wavelength;
    waveform.raw = snr_po_waveform_raw (result, sett);
    waveform.int = snr_po_waveform_int (result, sett, waveform.raw);
    waveform = snr_po_waveform_normalize (waveform, result);
    if (nargout < 1)
        snr_po_waveform_plot (waveform, sett)
    end
end

%%
function waveform_raw = snr_po_waveform_raw (result, sett)
  if isfieldempty(sett, 'fresnel_zone_max'),  sett.fresnel_zone_max = 15;  end  
  delay_sp = min(result.map.delay(:));
  delay_max = fresnel2delay (sett.fresnel_zone_max, result.info.wavelength) + delay_sp;
  
  % select only complete FZ (no truncated FZ):
  delay_border = result.map.delay(get_border_ind(result.map.delay));
  delay_border_min = min(delay_border);
  idx = (result.map.delay <= min(delay_border_min, delay_max));
  %idx = true(size(result.map.delay));  % DEBUG
  
  waveform_raw = struct();
  waveform_raw.delay = result.map.delay(idx);  
  waveform_raw.phasor_scattered = result.map.phasor_scattered(idx);
  %waveform_raw = snr_po_waveform_combine (waveform_raw, result);  % WAIT.
  waveform_raw.dist = sqrt(result.map.x(idx).^2 + result.map.y(idx).^2);  
end

%%
function waveform = snr_po_waveform_combine (waveform, result)
  waveform.phasor = waveform.phasor_scattered + result.phasor_direct;
  %waveform.phasor = waveform.phasor_scattered;  % DEBUG
  waveform.power = get_power(waveform.phasor);  
  waveform.snr = waveform.power ./ result.power_loss;
  waveform.snr_db = decibel_power(waveform.snr);
end

%%
function waveform_int = snr_po_waveform_int (result, sett, waveform_raw)
  sett = snr_po_waveform_raw_sett (sett, waveform_raw);
  waveform_int = struct();
  waveform_int.delay = sett.avg_posting;
  [waveform_int.phasor_scattered, waveform_int.count] = smoothit (...
    waveform_raw.delay, waveform_raw.phasor_scattered, ...
    sett.avg_window_width, waveform_int.delay, {@sum, @numel});
    % Don't smooth the combined or total phasor because:
    % - summing it will mishandle the direct phasor (it'll be duplicated)
    % - averaging it will mishandle the scattered phasor (in measurements, 
    %   it's summed not averaged -- especially not averaged over spatial domain)
  waveform_int = snr_po_waveform_combine (waveform_int, result);
end

%%
function waveform = snr_po_waveform_normalize (waveform, result)
    waveform.raw.count = naninterp1(waveform.int.delay, waveform.int.count, ...
        waveform.raw.delay);
    waveform.raw.phasor_scattered_original = waveform.raw.phasor_scattered;
    waveform.raw.phasor_scattered = waveform.raw.phasor_scattered .* waveform.raw.count;
    waveform.raw = snr_po_waveform_combine (waveform.raw, result);
end

%%
function sett = snr_po_waveform_raw_sett (sett, waveform_raw)
  if ~isfieldempty(sett, 'avg_posting')
    if ~isfieldempty(sett, 'avg_post_spacing')
      warning('snr:avg:epoch:input', ...
        ['Non-empty sett.avg_posting and sett.avg_post_spacing' ...
         'detected; the former is taking precedence over the latter.']);
    end
    sett.avg_post_spacing = nanmedian(diff(sett.avg_posting));
    sett.avg_posting = sett.avg_posting;
  else
    if isfieldempty(sett, 'avg_post_spacing'),  sett.avg_post_spacing = 5e-3;  end
    mylinspace = @(min, max, step) (floor(min/step)*step):step:(ceil(max/step)*step);
    mylinspace2 = @(x, step) mylinspace(min(x), max(x), step);
    sett.avg_posting = mylinspace2(waveform_raw.delay, sett.avg_post_spacing)';
  end
  
  if isfieldempty(sett, 'avg_window_width'),  sett.avg_window_width = 5e-2;  end
  if ischar(sett.avg_window_width)
    sett.avg_window_width = str2double(sett.avg_window_width) * sett.avg_post_spacing;
  end
end
