% Multipath signature in GPS SNR, carrier phase, and code pseudorange
% observables for an atypical setup. An LHCP-predominant antenna is
% installed upside-down, 1.5 m above seawater. Results for varying surface
% random roughness are shown in red, green, and blue, corresponding to
% surface height standard deviation values of 0, 7.1, and 10.0 cm,
% respectively.  L1 and C/A are assumed for the carrier frequency and code
% modulation
% 
% Fig. 9 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y
% 
% The second figure is unpublished: Interferometric power for an atypical 
% setup. An LHCP-predominant antenna is installed upside-down, 1.5 m above 
% seawater. Results for varying surface random roughness are shown in red, 
% green, and blue, corresponding to surface height standard deviation values
% of 0, 7.1, and 10.0 cm, respectively.  L1 and C/A are assumed for the 
% carrier frequency and code modulation.  Notice the zero-crossings in this 
% second figure delimit elevation angle ranges where code error exhibits 
% distinct behavior, as shown in the bottom panel of the main figure

sett0 = snr_settings_paper();
sett0.sat.num_obs = 2000;  % need more points to sample the throughs finely.
sett0.opt.freq_name = 'L1';  % (missing L2 gains for 3D choke-ring).
sett0.opt.code_name = 'C/A';
sett0.ant.model = 'LEIAR25';
sett0.ant.radome = 'NONE';
sett0.ref.ignore_vec_apc_arp = true;
sett0.ant.switch_left_right = true;
%sett0.opt.phase_approx_small = true;  % DEBUG

%%
sett0.ant.slope = 0;
sett0.ant.slope = 90;
sett0.ant.slope = 180;

%%
%material = {'copper', 'freshwater', 'wet ground', 'dry ground'};
sett0.sfc.material_bottom = 'seawater';
%sett0.sfc.material_bottom = 'dry ground';

%%
num_cases = 3;
roughness_lim = [0 35e-2];
roughness_lim = [0 10e-2];
%roughness_domain = linspace(roughness_lim(1), roughness_lim(2), num_cases)';
roughness_domain = linspace(roughness_lim(1)^2, roughness_lim(2)^2, num_cases)'.^(1/2);
siz = [num_cases 1];

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.sfc.height_std = roughness_domain(k);   end
setup0 = snr_setup(sett0);
setup  = cell_snr_resetup(sett, setup0);
result = cell_snr_fwd(setup);

%%
figure
  if sett0.opt.max_plot,  maximize();  end
  h = [];
  for k=1:num_cases
    mysubplot(3,1,1)
      hold on
      h(k,1)=myplot(setup{k}.sat.elev, result{k}.snr_db, '-k', 'LineWidth',2);
      ylabel('SNR (dB)')
      %h(k,1)=myplot(setup{k}.sat.elev, result{k}.mp_modul, '-k', 'LineWidth',2);
      %ylabel('Power (W/W)')
    mysubplot(3,1,2)
      hold on
      h(k,2)=myplot(setup{k}.sat.elev, result{k}.carrier_error*1e3, '-k', 'LineWidth',2);
      ylabel('Phase (mm)')
    mysubplot(3,1,3)
      hold on
      h(k,3)=myplot(setup{k}.sat.elev, result{k}.code_error*1e2, '-k', 'LineWidth',2);
      ylabel('Code (cm)')
      xlabel('Elevation angle (degrees)')
  end
  %assert(num_cases == 4)
  set(h(1,:), 'Color','r')
  set(h(2,:), 'Color','g')
  set(h(3,:), 'Color','b')
  %if isequal(sett0.sat.elev_lim, [0 90]),  set(gca, 'XTick',0:15:90);  end
  for i=1:2
    mysubplot(3,1,i)
    set(gca, 'XTickLabel',[])
  end
  for i=1:3
    mysubplot(3,1,i)
    grid on
    axis tight
    yl = ylim();  ylim(yl+[-1,+1]*0.1/2*diff(yl))
  end
  mysubplot(3,1,2),  set(gca, 'YTick',get(gca, 'YTick')./2)  % avoid collision between ylabels across mysubplots.
  %mysubplot(3,1,1),  myplabel(h(:,1), num2str(roughness_domain*100, '%.1f cm'), [75 2.5])
  mysubplot(3,1,3),  ylim([-100 400]),  set(gca, 'YTick',-100:100:400)
  mysubplot(3,1,1),  set(gca(), 'YTickLabel',strcats('    ', get(gca(), 'YTickLabel')))  % align y labels.
  mysubplot(3,1,2),  set(gca(), 'YTickLabel',strcats('  ',  get(gca(), 'YTickLabel')))  % align y labels.
  legend(h(:,3), num2str(roughness_domain*100, '% 4.1f cm'), 'Location','NorthWest')
  %end
  %mysaveas(['20b-' num2str(sett0.ant.slope) '-' strrep(sett0.sfc.material_bottom, ' ','_')])
  mysaveas('figA9')

%%
figure
  if sett0.opt.max_plot,  maximize();  end
  hold on
  myxlim(sett0.sat.elev_lim)
  hline(0, {'--k', 'LineWidth',2})
  h = [];
  for k=1:num_cases
    h(k) = myplot(setup{k}.sat.elev, decibel_phasor(result{k}.phasor_interf), '-k', 'LineWidth',1*k);
  end
  %if isequal(sett0.sat.elev_lim, [0 90]),  set(gca, 'XTick',0:15:90);  end
  grid on
  myplabel(h, num2str(roughness_domain*100, '%.1f cm'), [62.5 2.5])
  xlabel('Elevation angle (degrees)')
  ylabel('Interferometric power (dB)')
  set(h(1), 'Color','r')
  set(h(2), 'Color','g')
  set(h(3), 'Color','b')
  %mysaveas(['20a-' num2str(sett0.ant.slope) '-' strrep(sett0.sfc.material_bottom, ' ','_')])
  mysaveas('figA9-alt')
