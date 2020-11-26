% Effect of antenna model on interferometric power. Combinations of two
% surface materials and three geodetic-quality antenna models are compared.
% Soil is shown in green, copper in red; chokering, zephyr, and 3D
% choke-ring (IGS antenna codes TRM29659.00, TRM55971.00, and LEIAR25) are
% shown, respectively, in solid, dashed, and dash-dot line styles. L1 and
% C/A are assumed for the carrier frequency and code modulation
% 
% Fig. 7 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper ();
sett0.ref.ignore_vec_apc_arp = true;
sett0.opt.freq_name = 'L1';  % (missing L2 gains for 3D choke-ring).
sett0.opt.code_name = 'C/A';

%%
temp = {...
  'TRM29659.00', 'NONE', 'Choke-ring';
  'TRM55971.00', 'NONE', 'Zephyr';
  'LEIAR25', 'NONE', '3D choke-ring';
};
antenna_domain = cell2struct(temp, {'model','radome','label'}, 2);
%material_domain = {'copper', 'freshwater', 'wet ground', 'dry ground'};
material_domain = {'copper', 'soil fixed'};
num_materials = numel(material_domain);
num_antennas = numel(antenna_domain);
siz = [num_antennas num_materials];
num_cases = prod(siz);
%[material_grid, antenna_grid] = meshgrid(material_domain, antenna_domain);
[material_grid2, antenna_grid2] = meshgrid(1:num_materials, 1:num_antennas);
material_grid = material_domain(material_grid2);
antenna_grid = antenna_domain(antenna_grid2);

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.sfc.material_bottom = material_grid(k);   end
for k=1:num_cases,  sett{k}.ant = structmerge(sett0.ant, antenna_grid(k));  end
setup0 = snr_setup(sett0);
setup  = snr_resetup(sett, setup0);
result = snr_fwd(setup);

%%
%if is_octave(),  ogt = graphics_toolkit('fltk');  end
figure
  if sett0.opt.max_plot,  maximize();  end
  hold on
  ls = {...
      '-r' '-g' '-b' '-k'
      '--r' '--g' '--b' '--k'
      '-.r' '-.g' '-.b' '-.k'
  };
  h = [];
  for i=1:num_antennas
  for j=1:num_materials
    h(i,j) = myplot(setup{i,j}.sat.elev, decibel_phasor(result{i,j}.phasor_interf), ls{i,j}, 'LineWidth',2);
  end
  end
  %myxlim(sett0.sat.elev_lim)
  %if isequal(sett0.sat.elev_lim, [0 90]),  set(gca, 'XTick',0:15:90);  end
  grid on
  %temp = arrayfun(@(k) sprintf('%s (%s)', capitalize(material_grid{k}), antenna_grid(k).label), reshape(1:num_cases, siz), 'UniformOutput',false);
  %myplabel(h, temp)
  %myplabel(h(:,1), temp(:,1), [3 1])
  %myplabel(h(:,2), temp(:,2))%, [3 1])  
  legend(h(:,1), {antenna_domain.label}, 'Location','SouthWest')
  xlabel('Elevation angle (degrees)')
  ylabel('Interferometric power (dB)')
  if ~is_octave()
    temp = {'EdgeColor','none', 'FontWeight','bold', 'FontSize',get(0, 'DefaultAxesFontSize'), 'Margin',0};
    annotation('textbox',[0.63 0.70 0.1 0.1], 'String','Copper', 'Color','r', temp{:})
    annotation('textbox',[0.63 0.65 0.1 0.1], 'String','Soil',   'Color','g', temp{:})
  end
  mysaveas('figA7')
  %if is_octave(),  graphics_toolkit(ogt);  end
