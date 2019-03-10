% Non-sinusoidal interference fringes for increasingly more realistic
% simulations: (1) idealized case; (2) enabling variable incident satellite
% power trend; (3) enabling surface random roughness; (4) enabling
% non-perfect electrically conducting surface material; (5) enabling the
% receiving antenna gain pattern. Each case is normalized by the respective
% median direct power with no detrending.
% 
% Fig. 4 in Nievinski, F.G. and Larson, K.M., "An open source GPS multipath
% simulator in Matlab/Octave", GPS Solut. (in press)

sett_defaults = snr_settings();

sett0 = sett_defaults;
sett0.ref.height_ant = get_gps_wavelength()*2.75;
sett0.sat.elev_lim = [0, 90];
sett0.sat.num_obs = 1000/2;
sett0.ref.ignore_vec_apc_arp = true;
sett0.opt.dsss.disable = true;
sett0.opt.incid_polar_power = 0;
sett0.sfc.material_bottom = 'pec';
sett0.ant.model = 'isotropic';
sett0.ant.radome = 'none';
%sett0.ant.polar_phase = 0;
sett0.sfc.height_std = 0;
sett0.opt.disable_incident_power_trend = true;

%%
sett = {sett0};

sett{end+1} = sett{end};
sett{end}.opt.disable_incident_power_trend = false;

sett{end+1} = sett{end};
sett{end}.sfc.height_std = 5e-2;

sett{end+1} = sett{end};
sett{end}.sfc.material_bottom = 'soil fixed';

sett{end+1} = sett{end};
sett{end}.ant.model = sett_defaults.ant.model;
sett{end}.ant.radome = sett_defaults.ant.radome;
sett{end}.ant.polar_phase = sett_defaults.ant.polar_phase;

%%
setup0 = snr_setup(sett0);
setup = cellfun2(@(setti) snr_resetup(setti, setup0), sett);
result = cellfun2(@snr_fwd, setup);

%%
for i=1:numel(result)
  temp = {result{i}.phasor_direct, result{i}.phasor_reflected, ...
          false, false, result{i}.phasor_direct, ...
          false, false, setup0.sat.elev, 0};
  result{i}.mp_modul = get_multipath_modulation (temp{:});
end

%%
n = numel(result);
try
  color = distinguishable_colors(n-1);  % relies on image toolbox.
catch
  color = jet(n-1);
end
color = vertcat([1 1 1]*0.5, color);
color = flipud(color);
figure
  if sett0.opt.max_plot,  maximize();  end
  hold on
  grid on
  for i=1:n
    plotsin(setup0.sat.elev, result{i}.mp_modul, '-k', 'LineWidth',2, ...
      'Color',color(i,:))
    %if (i ~= n),  pause;  end
  end
  %set(gca, 'XTickLabel',num2str(asind(get(gca, 'XTick'))', '%.1f'))
  legend(num2str((1:n)'), 'Location','South', 'Orientation','horizontal')
  ylabel('Composite power (W/W)')
  xlabel('Elevation angle (degrees)')
  ylim([-1 +1]*1.1)
  hline(0, ':k')
  %fixfig()
  mysaveas('figB4')
