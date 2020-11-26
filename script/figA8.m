% Effect of antenna orientation on interferometric power.  Combinations of
% two surface materials and two antenna orientations are compared. Soil is
% shown in green, copper in red; upright and tipped orientations are shown,
% respectively, in solid and dashed line styles
% 
% Fig. 8 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper();
sett0.ant.model = 'TRM29659.00';
sett0.ant.radome = 'SCIT';
sett0.ref.ignore_vec_apc_arp = true;

%%
% slope_domain = {'upright', 'tipped', 'upside-down'};
% material_domain = {'copper', 'freshwater', 'wet ground', 'dry ground'};
% material_label_domain = material_domain;
slope_domain = {'upright', 'tipped'};
material_domain = {'copper', 'soil fixed'};
material_label_domain = {'copper', 'soil'};
num_materials = numel(material_domain);
num_slopes = numel(slope_domain);
siz = [num_slopes num_materials];
num_cases = prod(siz);
%[material_grid, slope_grid] = meshgrid(material_domain, slope_domain);
[material_grid2, slope_grid2] = meshgrid(1:num_materials, 1:num_slopes);
slope_grid = slope_domain(slope_grid2);
material_grid = material_domain(material_grid2);
material_label_grid = material_label_domain(material_grid2);

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.sfc.material_bottom = material_grid(k);   end
for k=1:num_cases,  sett{k}.ant.slope = slope_grid{k};   end
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
  for i=1:num_slopes
  for j=1:num_materials
    h(i,j) = myplot(setup{i,j}.sat.elev, decibel_phasor(result{i,j}.phasor_interf), ls{i,j}, 'LineWidth',2);
  end
  end
  %myxlim(sett0.sat.elev_lim)
  %if isequal(sett0.sat.elev_lim, [0 90]),  set(gca, 'XTick',0:15:90);  end
  grid on
  legend(h(:,1), capitalize(slope_domain), 'Location','SouthWest')
  %myplabel(h, temp, [70 5])
  xlabel('Elevation angle (degrees)')
  ylabel('Interferometric power (dB)')
  temp = {'EdgeColor','none', 'FontWeight','bold', 'FontSize',get(0, 'DefaultAxesFontSize'), 'Margin',0};
  if ~is_octave()
    annotation('textbox',[0.63 0.70 0.1 0.1], 'String','Copper', 'Color','r', temp{:})
    annotation('textbox',[0.63 0.65 0.1 0.1], 'String','Soil',   'Color','g', temp{:})
  end
  mysaveas('figA8')
  %if is_octave(),  graphics_toolkit('ogt');  end
