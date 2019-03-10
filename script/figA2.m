% Magnitude and phase of modeled signals. Top panel: reflected, direct,
% interferometric, composite, and error magnitudes; bottom panel:
% interferometric and error phases. These are the underlying constituting
% quantities responsible for producing the observable signatures presented
% in Fig. 1
% 
% Fig. 2 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett = snr_settings_paper ();
setup = snr_setup (sett);
result = snr_fwd (setup);

result.phase_error  = get_phase(result.phasor_error);
result.phase_geom   = get_phase(result.reflected.phasor_delay);
result.phase_compos = get_phase_compositional(result);

%%
f = @abs;  lab = 'Magnitude (V/V)';
%f = @get_power;  lab = 'Power (W/W)';
h = [];
figure
if sett.opt.max_plot,  maximize();  end
mysubplot(2,1,1)
  hold on
  temp = max(f(result.phasor_direct));
  h(end+1) = myplot(setup.sat.elev, f(result.phasor_reflected)./temp, '-.b',  'LineWidth',2);%, 'Color',[1 1 1]*0.50)
  h(end+1) = myplot(setup.sat.elev, f(result.phasor_direct)./temp,    '-.g',  'LineWidth',2);%, 'Color',[87 157 28]./255)
  h(end+1) = myplot(setup.sat.elev, f(result.phasor_interf),          '--k',  'LineWidth',2);%, 'Color',[1 1 1]*0.75)
  h(end+1) = myplot(setup.sat.elev, f(result.phasor_composite)./temp, '-',    'LineWidth',2, 'Color',[255, 211, 32]./255);
  h(end+1) = myplot(setup.sat.elev, f(result.phasor_error),           '-r',   'LineWidth',2);%, 'Color',[1 1 1]*0.25)
  ylabel(lab)
  temp = {'Reflected','Direct','Interferometric','Composite','Error'};
  legend(myflip(h), myflip(temp), 'Location','SouthEast')
  set(gca(), 'XTickLabel',[])
  if ~is_octave()
    set(gca(), 'YTickLabel',strcats('   ', get(gca(), 'YTickLabel')))  % align y labels.
  end
mysubplot(2,1,2)
  hold on
  myplot(setup.sat.elev, result.phase_geom,   '--k', 'LineWidth',2, 'Color',[1 1 1]*0.50)
  myplot(setup.sat.elev, result.phase_compos, '--k', 'LineWidth',2)%, 'Color',[1 1 1]*0.50)
  myplot(setup.sat.elev, result.phase_error,  '-r',  'LineWidth',2)%, 'Color',[1 1 1]*0.25)
  temp = {sprintf('Interferometric\n(geometrical)'),sprintf('Interferometric\n(compositional)'),'Error'};
  legend(temp, 'Location','NorthEast')
  set(gca, 'YTick',-180:90:+180)
  ylabel('Phase (degrees)')
  xlabel('Elevation angle (degrees)')
for i=1:2
  mysubplot(2,1,i)
  grid on
  axis tight
  yl = ylim();  ylim(yl+[-1,+1]*0.1/2*diff(yl))
end
mysaveas('figA2')


