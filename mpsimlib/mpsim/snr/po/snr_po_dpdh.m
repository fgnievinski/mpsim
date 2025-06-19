function [answers, dpower_dh] = snr_po_dpdh (answers, sett, pre, mode, ...
dh, name1, name2, name3, as_density, ...
detrendit, normalizeit, ref_phasor_type)
    if (nargin < 3),  pre = struct();  end
    if (nargin < 4) || isempty(mode),  mode = 'multipath';  end
    if (nargin < 5) || isempty(dh),  dh = 1e-3;  end
    if (nargin < 6) || isempty(name1),  name1 = 'direct';  end
    if (nargin < 7) || isempty(name2),  name2 = 'phasor';  end
    if (nargin < 8) || isempty(name3),  name3 = 'dpower_dh';  end
    if (nargin < 9) || isempty(as_density),  as_density = true;  end
    if (nargin <10),  detrendit = [];  end
    if (nargin <11),  normalizeit = [];  end
    if (nargin <12),  ref_phasor_type = [];  end  
    assert(isfield(answers(1).map, name2))
    field = {name2};  % good idea?
    
    %if isfield(pre, 'dir_scatt'),  pre.dir_scatt_original = pre.dir_scatt;  end  % EXPERIMENTAL!
    temp = {'pos_sfc', 'dir_normal', 'vec_zgrad', 'dA', 'patch_list', 'dir_scatt_original'};
    pre = getfields(pre, temp, true);
    [ignore, answers_lo] = snr_po_dh (-dh, sett, field, pre); %#ok<ASGLU>
    pre = getfields(pre, temp, true);
    [ignore, answers_hi] = snr_po_dh (+dh, sett, field, pre); %#ok<ASGLU>
    
    n = numel(answers);
    dpower_dh = cell(n,1);
    for i=1:n
        dpower_dh{i} = snr_po_dpdh_aux (mode, dh, answers(i).(name1).phasor, ...
            answers(i).map.(name2), answers_lo(i).map.(name2), answers_hi(i).map.(name2), ...
            detrendit, normalizeit, ref_phasor_type);
        if as_density
            %dpower_dh{i} = dpower_dh{i} ./ answers(i).info.dA;  % WRONG!
            dpower_dh{i} = dpower_dh{i} ./ answers(i).info.dA_horiz;
        end
        answers(i).map.(name3) = dpower_dh{i};
    end
end

function [snr_db, answers] = snr_po_dh (dh, sett, field, pre)
  if (nargin < 3),  field = [];  end
  if (nargin < 4),  pre = [];  end

  sett.ref.height_ant = ...
  sett.ref.height_ant + dh;

  [sat, sfc, ant, ref, opt] = snr_fwd_setup (sett);
  
  [snr_db, answers] = snr_po_run (sat, sfc, ant, ref, opt, field, pre);
end

function map_dpower_dh = snr_po_dpdh_aux (mode, dh, ...
scalar_direct_phasor, map_element_phasor, ...
map_element_phasor_lo, map_element_phasor_hi, ...
detrendit, normalizeit, ref_phasor_type)
  [map_power_lo, map_power_hi] = snr_po_dpdh_aux2 (mode, ...
    scalar_direct_phasor, map_element_phasor, ...
    map_element_phasor_lo, map_element_phasor_hi, ...
    detrendit, normalizeit, ref_phasor_type);
  map_dpower_dh = (map_power_hi - map_power_lo) ./ (2*dh);
end
  
function [map_power_lo, map_power_hi] = snr_po_dpdh_aux2 (mode, ...
scalar_direct_phasor, map_element_phasor, ...
map_element_phasor_lo, map_element_phasor_hi, ...
detrendit, normalizeit, ref_phasor_type)
  if (nargin < 6),  detrendit = [];  end
  if (nargin < 7) || isempty(normalizeit),  normalizeit = true;  end
  if (nargin < 8),  ref_phasor_type = [];  end
  
  scalar_net_phasor = nansum(nansum(map_element_phasor));
  
  if strcmpi(mode, 'scattered')
    map_power_lo = get_power (map_element_phasor_lo);
    map_power_hi = get_power (map_element_phasor_hi);
    [map_power_lo, map_power_hi] = snr_po_dpdh_aux3 (...
      scalar_direct_phasor, scalar_net_phasor, ...
      map_power_lo, map_power_hi, ...
      normalizeit, ref_phasor_type);
    return;
  end
  
  temp = scalar_net_phasor - map_element_phasor;  % remove mid contribution
  map_net_phasor_lo = temp + map_element_phasor_lo;
  map_net_phasor_hi = temp + map_element_phasor_hi;
    clear temp
    clear map_element_phasor_lo map_element_phasor_hi
  
  if strcmpi(mode, 'reflected')
    map_power_lo = get_power (map_net_phasor_lo);
    map_power_hi = get_power (map_net_phasor_hi);
    [map_power_lo, map_power_hi] = snr_po_dpdh_aux3 (...
      scalar_direct_phasor, scalar_net_phasor, ...
      map_power_lo, map_power_hi, ...
      normalizeit, ref_phasor_type);
    return;
  end
  
  if ~strcmpi(mode, 'multipath')
    error('snr:snr_po_dpdh:unkMod', 'Unknown mode "%s".', mode);
  end
  
  if isempty(ref_phasor_type),  ref_phasor_type = 'self';  end
  switch lower(ref_phasor_type)
  case 'none'
    ref_phasor = 1;
  case 'net'
    ref_phasor = scalar_net_phasor;
  case 'self'
    ref_phasor = [];
  otherwise
    error('snr:snr_po_dpdh_aux:unkType', ...
      'Unknown ref_phasor_type = "%s".', ref_phasor_type);
  end    
  get_multipath_modulation2 = @(phasor) get_multipath_modulation (...
      scalar_direct_phasor, phasor, detrendit, normalizeit, ref_phasor);
  %scalar_multipath_power = get_multipath_modulation2 (scalar_net_phasor);
  
  map_power_lo = get_multipath_modulation2 (map_net_phasor_lo);
  map_power_hi = get_multipath_modulation2 (map_net_phasor_hi);
end

function [map_power_lo, map_power_hi] = snr_po_dpdh_aux3 (...
scalar_direct_phasor, scalar_net_phasor, ...
map_power_lo, map_power_hi, ...
normalizeit, ref_phasor_type)
  if (nargin < 5) || isempty(normalizeit),  normalizeit = true;  end
  if (nargin < 6),  ref_phasor_type = [];  end
  if ~normalizeit,  return;  end
  if isempty(ref_phasor_type),  ref_phasor_type = 'direct';  end
  switch lower(ref_phasor_type)
  case 'none'
    ref_phasor = 1;
  case 'net'
    ref_phasor = scalar_net_phasor;
  case 'direct'
    ref_phasor = scalar_direct_phasor;
  otherwise
    error('snr:snr_po_dpdh_aux:unkType', ...
      'Unknown ref_phasor_type = "%s".', ref_phasor_type);
  end
  scalar_direct_power = get_power (scalar_direct_phasor);
  ref_power = get_power (ref_phasor);
  temp = sqrt(scalar_direct_power) .* sqrt(ref_power);
  map_power_lo = map_power_lo ./ temp;
  map_power_hi = map_power_hi ./ temp;
end
