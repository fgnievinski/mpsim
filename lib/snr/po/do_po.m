%%clear
%%base_dir = 'c:\work\experiment\20100822a - gps-ir, PO map, sums\';
%%base_dir = 'c:\work\experiment\20110223a - gps-ir, main scattering area\PO\';
%base_dir = 'c:\work\experiment\20110402a - gps-ir, normal incidence\';
%m_dir = 'c:\work\m';
%addpath(genpath(m_dir))
%cd(base_dir)
%warning('off', 'matlab:get_permittivity:badFreq')

%height = 1;
height = 2;
height = 2 - 117.16e-3;
%height = 5;
%height = 10;
elev = 20;
%elev = [20; 30]
%elev = linspace(10, 30, 50)';
%elev = 21;
%elev = 5;
%elev = 45;
%elev = 50;
%elev = 35;
azim = 0; %-45; %45+180;

sett = snr_fwd_settings ();
sett.sfc.material_bottom = 'wet ground';
sett.sfc.material_bottom = 'dry ground';
%sett.sfc.material_bottom = 'steel';
%sett.sfc.material_bottom = 'pec';
sett.sfc.slope = 0;
sett.sfc.aspect = 0;
sett.ant.slope =  0;  sett.ant.aspect = 0;
%sett.ant.slope = 90;  sett.ant.aspect = 0;
%sett.ant.slope = 90;  sett.ant.aspect = azim + 180;
%sett.ant.slope = 90;  sett.ant.aspect = azim + 90;
%%sett.ant.slope = 90 + elev;  sett.ant.aspect = azim;
%sett.sfc.height_std = [];
sett.opt.polar_ellipticity_beta = 0;
sett.opt.freq_name = 'L2';
sett.opt.code_name = 'L2C';
sett.opt.block_name = 'IIR-M';
sett.ant.model = 'TRM29659.00';  sett.ant.radome = 'SCIT';
sett.ant.model = 'isotropic';  sett.ant.radome = '';
sett.ref.height_ant = height;
%sett.opt.polar_ellipticity_beta = 0.12597;
sett.sat.elev = elev;
sett.sat.azim = azim;
[sat, sfc, ant, ref, opt] = snr_fwd_setup (sett);

lim = 10;  step = 0.025;
lim = 25;  step = 0.05;
%%lim = 50;  step = 0.1;
%%lim = 75;  step = 0.15;
%%lim = [-30,+30, -15,+125];  step = 0.10;
%%lim = [-30,+30, -15,+125];  step = 0.05;
%lim = [-25,+25, -15,+50];  step = 0.05;
lim = [-25,+25, -15,+50];  step = 0.05;
lim = [-25,+25, -15,+50];  step = 0.075;
lim = [-25,+25, -15,+50];  step = 0.1;
lim = 25;  step = 0.10;
lim = [-10,+10, -5,+25];  step = 0.10;
lim = [-10,+10, -5,+25];  step = 0.15;
lim = [-10,+10, -5,+50];  step = 0.20;
lim = [-10,+10, -5,+25];  step = 0.10;
%lim = [-10,+10, -5,+50];  step = 0.10;
%lim = [-10,+10, -5,+25];  step = 0.075;
%lim = [-10,+10, -5,+25];  step = 0.;
%lim = [-10,+10, -10,+25];  step = 0.10;
%lim = 2.5;  step = 0.01;
%lim = [-25,+25, -15,+50];  step = 0.025;
%lim = [-25,+25, -15,+50];  step = [0.035 0.05];
%lim = [-25,+25, -15,+50];  step = 0.035;
%%lim = 10;  step = 0.025;
%lim = 10;  step = 0.05;
opt.lim = lim;
opt.step = step;

tic
[go_snr_db, go_answer, go_carrier_error, go_code_error] = snr_fwd_run (sat, sfc, ant, ref, opt);
[po_snr_db, po_answer, po_carrier_error, po_code_error] = snr_po_run (sat, sfc, ant, ref, opt);
toc

figure
subplot(3,1,1)
  hold on
  plot(sat.elev, po_snr_db, 'o-k')
  plot(sat.elev, go_snr_db, '.-r')
  grid on
  ylabel('SNR (dB)')
subplot(3,1,2)
  hold on
  plot(sat.elev, po_carrier_error*1000, 'o-k')
  plot(sat.elev, go_carrier_error*1000, '.-r')
  grid on
  ylabel('Carrier error (mm)')
subplot(3,1,3)
  hold on
  plot(sat.elev, po_code_error*100, 'o-k')
  plot(sat.elev, go_code_error*100, '.-r')
  grid on
  ylabel('Code error (cm)')
  xlabel('Elevation angle (degrees)')
maximize()

% go = [go_snr_db, go_carrier_error, go_code_error];
% po = [po_snr_db, po_carrier_error, po_code_error];
%   display([go; NaN(1,3); po; NaN(1,3); po-go; NaN(1,3); 100.*(po-go)./go])
  
return


%opt.height_std = [];  opt.use_two_angle_roughness = false;
% opt.height_std = 10e-2;  opt.use_two_angle_roughness = false;
%opt.height_std = 10e-2;  opt.use_two_angle_roughness = true;
%opt.height_std = 15e-2;  opt.use_two_angle_roughness = true;
%opt.height_std = 25e-2;  opt.use_two_angle_roughness = true;
% opt.height_std = 50e-2;  opt.use_two_angle_roughness = true;

%opt.use_two_angle_roughness = true;

answer = calc_diffraction (elev, azim, ant, opt);
answer = calc_diffraction2 (elev(1), azim(1), ant, opt);
[snr_db, answers] = calc_diffraction_series2 (elev, azim, ant, opt);
[snr_db, answers] = calc_diffraction_series2 (elev(1:2), azim(1:min(end,2)), ant, opt, {'*'});
answer = calc_diffraction_aux (answer);
%answer = calc_diffraction2 (elev, azim, ant, opt);
%answer = calc_diffraction_aux (answer);

plotpo(answer, @(map) map.S, 'jet')


return

%plotpo(answer, @(map) map.delay, 'jet')plotpo(answer, @(map) map.delay, 'jet')
%plotpo(answer, @(map) map.C, 'jet'),  set(gca, 'CLim',[0,1])
%plotpo(answer, @(map) 1-map.C, 'jet'),  set(gca, 'CLim',[0,1])
%%plotpo(answer, @(map) 1./map.C, 'jet')
%plotpo2(answer, @(map) map.delay, [], [], 10)
%plotpo2(answer, @(map) map.C, [], [], 10),  %zlim([0,1])

plotpo(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % how cum phasor changes in power
%plotpo(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'cptcmap(''dkbluered'', ''ncol'',100)')  % how cum phasor changes in power


plotpo(answer, @(map) 100*abs(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
plotpo(answer, @(map) 100*(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - answer.map.mphasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - answer.map.mphasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
%plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - answer.map.mphasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'cptcmap(''earth'', ''ncol'',100)')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*get_power(answer.map.mphasor)./get_power(answer.net.phasor)./answer.dA, 'jet', [], [], '%/m^2')




plotpo(answer, @(map) 100*abs(get_power(answer.composite.phasor - answer.map.phasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
plotpo(answer, @(map) 100*(get_power(answer.composite.phasor - answer.map.phasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - answer.map.phasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - answer.map.phasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
%plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - answer.map.phasor) - get_power(answer.net.phasor) ) ./ get_power(answer.net.phasor), 'cptcmap(''earth'', ''ncol'',100)')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode


return

plotpo(answer, @(map) get_power(map.perm_bottom), 'jet')
plotpo(answer, @(map) get_power(map.elev_scatt), 'jet')

plotpo(answer, @(map) get_power(map.phasor), 'jet')
plotpo(answer, @(map) get_power(map.phasor_rhcp), 'jet')
plotpo(answer, @(map) get_power(map.phasor_lhcp), 'jet')

plotpo(answer, @(map) get_power(map.F_same), 'jet'),  set(gca, 'CLim',[0,1])
plotpo(answer, @(map) get_power(map.F_cross), 'jet'),  set(gca, 'CLim',[0,1])
plotpo(answer, @(map) get_power(map.F_rhcp), 'jet'),  set(gca, 'CLim',[0,1])
plotpo(answer, @(map) get_power(map.F_lhcp), 'jet'),  set(gca, 'CLim',[0,1])

plotpo(answer, @(map) get_power(map.G_rhcp), 'jet')
plotpo(answer, @(map) get_power(map.G_lhcp), 'jet')
plotpo2(answer, @(map) get_power(map.G_rhcp))
plotpo2(answer, @(map) get_power(map.G_lhcp))
plotpo(answer, @(map) 100*(abs(map.G_lhcp) ./ abs(map.G_rhcp) - 1), 'bwr')
plotpo2(answer, @(map) 100*(abs(map.G_lhcp) ./ abs(map.G_rhcp) - 1))
antenna_gain_plot5 (ant.gain.rhcp, ant.gain.lhcp)


plotpo(answer, @(map) 100*get_power(map.mphasor)./get_power(answer.net.phasor), 'jet')  % if I were to image only one 1-m^2 portion
plotpo(answer, @(map) 100*(get_power(answer.direct.phasor + map.mphasor) - get_power(answer.direct.phasor))./get_power(answer.direct.phasor), 'bwr')  % if I were to image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.mphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion
plotpo(answer, @(map) 100*(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - map.mphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion
plotpo(answer, @(map) 100*abs(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
plotpo2(answer, @(map) 100*abs(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor))  % if I were to NOT image only one 1-m^2 portion, in interferometric mode

plotpo(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % how cum phasor changes in power
plotpo(answer, @(map) 100*abs(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')  % how cum phasor changes in power
%plotpo(answer, @(map) 100*abs(get_power(map.cphasor) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor), 'jet')  % how cum phasor changes in power
plotpo(answer, @(map) 100*get_power(map.cphasor - answer.composite.phasor)./get_power(answer.composite.phasor), 'jet')  % how cum phasor converges to composite phasor, in terms of power
plotpo(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), 'jet')  % how cum phasor converges to net phasor, in terms of power
plotpo(answer, @(map) 100*(get_power(answer.direct.phasor + map.cphasor) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor), 'bwr')  % how multipath modulation converges, in terms of power of composite signal
plotpo2(answer, @(map) 100*(get_power(answer.direct.phasor + map.cphasor) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor))  % how multipath modulation converges, in terms of power of composite signal

plotpo(answer, @(map) (100*get_power(answer.net.phasor - map.phasor)./get_power(answer.net.phasor)-100), 'bwr')
%plotpo(answer, @(map) (100*(get_power(answer.direct.phasor + answer.map.phasor) - get_power(answer.direct.phasor))./get_power(answer.direct.phasor)), 'bwr')
plotpo(answer, @(map) (100*(get_power(answer.composite.phasor + answer.map.phasor) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor)), 'bwr')
plotpo(answer, @(map) abs(100*(get_power(answer.net.phasor + answer.map.phasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor)), 'jet')
%plotpo(answer, @(map) abs(100*(get_power(answer.direct.phasor + answer.map.phasor) - get_power(answer.direct.phasor))./get_power(answer.direct.phasor)), 'jet')
plotpo(answer, @(map) abs(100*(get_power(answer.composite.phasor + answer.map.phasor) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor)), 'jet')


return

%plotpo(answer, @(ignore) rand(size(answer.map.phasor)), 'jet')
%plotpo(answer, @(ignore) rand(size(answer.map.phasor)./10), 'jet')

answer.map.real = real(answer.map.phasor);
answer.map.imag = imag(answer.map.phasor);
plotpo3(answer, 75, 1/(abs(answer.net.phasor)/answer.num_elements)*1e-2)
plotpo3(answer, 75, 1/(abs(answer.net.phasor)/answer.num_elements)*1e-2, true)


plotpo(answer, @(map) (100*get_power(answer.map.phasor)./get_power(answer.net.phasor)), 'jet')
plotpo2(answer, @(map) 100*get_power(answer.map.phasor)./get_power(answer.net.phasor))
plotpo(answer, @(map) (100*get_power(answer.net.phasor - map.phasor)./get_power(answer.net.phasor)-100), 'bwr')
plotpo2(answer, @(map) 100*get_power(answer.net.phasor - map.phasor)./get_power(answer.net.phasor)-100)
plotpo(answer, @(map) abs(100*get_power(answer.net.phasor - map.phasor)./get_power(answer.net.phasor)-100), 'jet')
plotpo2(answer, @(map) abs(100*get_power(answer.net.phasor - map.phasor)./get_power(answer.net.phasor)-100))


plotpo(answer, @(map) 100*(abs(map.cphasor) - abs(answer.net.phasor))./abs(answer.net.phasor), 'bwr')  % how cum phasor changes in ampl
plotpo(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % how cum phasor changes in power
plotpo2(answer, @(map) 100*(get_power(map.cphasor))./get_power(answer.net.phasor))  % how cum phasor changes in power
plotpo2(answer, @(map) 100*(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))  % how cum phasor changes in power
plotpo2(answer, @(map) 100*abs(get_power(map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))  % how cum phasor changes in power
plotpo(answer, @(map) get_phase(map.cphasor) - get_phase(answer.net.phasor), 'hsv')  % how cum phasor changes in phase
plotpo(answer, @(map) get_phase(map.cphasor), 'hsv'), set(gca, 'CLim',[-180,+180])  % how cum phasor changes in phase
plotpo(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), 'jet')  % how cum phasor converges to net phasor, in terms of power
plotpo2(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor))  % how cum phasor converges to net phasor, in terms of power
%plotpo2(answer, @(map) 100*(get_power(map.cphasor - answer.net.phasor)-get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')  % how cum phasor converges to net phasor, in terms of power
plotpo(answer, @(map) get_phase(map.cphasor - answer.net.phasor), 'hsv'), set(gca, 'CLim',[-180,+180])  % how cum phasor converges to net phasor, in terms of phase
plotpo4(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), @(map) map.cphasor - answer.net.phasor, 75, (1e+11)/2)
answer.map.real = real(answer.map.cphasor - answer.net.phasor);
  answer.map.imag = imag(answer.map.cphasor - answer.net.phasor);
  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/2)
  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/2, true)
answer.map.real = real(answer.map.cphasor);
  answer.map.imag = imag(answer.map.cphasor);
  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/3)
  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/3, true)
%ind = round(linspace(1, answer.num_elements, 500*3));  
%figure, feather(answer.map.cphasor(answer.map.ind0(ind))./answer.net.phasor)
%figure, feather((answer.map.cphasor(answer.map.ind0(ind))-answer.net.phasor)./answer.net.phasor)

temp = answer.map.fresnel_zone_number;
temp(temp > 15) = NaN;
plotpo(answer, @(map) temp, 'flipud(gray)')

xmax = 20;
xmax = 125;
xmax = 50;
%ind = answer.map.ind0(:);
ind = answer.map.ind0(answer.map.fresnel_zone(answer.map.ind0(:)) < xmax);
  %figure, plot(answer.map.fresnel_zone(ind))
figure
subplot(3,1,1)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power(answer.map.cphasor(ind))./get_power(answer.net.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  ylim([-100,+350])
  set(gca, 'XGrid','on')
subplot(3,1,2)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.net.phasor - answer.map.cphasor(ind) )./get_power(answer.net.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
subplot(3,1,3)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.net.phasor - answer.map.cphasor(ind) )./get_power(answer.net.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [100;100], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
%figure, plot(get_phase(answer.map.cphasor(ind)))
%figure, feather((answer.map.cphasor(ind))./answer.net.phasor)
%figure, feather((answer.map.cphasor(ind)-answer.net.phasor)./answer.net.phasor)

xmax = 20;
xmax = 125;
xmax = 50;
%ind = answer.map.ind0(:);
ind = answer.map.ind0(answer.map.fresnel_zone(answer.map.ind0(:)) < xmax);
  %figure, plot(answer.map.fresnel_zone(ind))
figure
subplot(3,1,1)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power(answer.map.cmphasor(ind))./get_power(answer.net.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  ylim([-100,+350])
  set(gca, 'XGrid','on')
subplot(3,1,2)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.net.phasor - answer.map.cmphasor(ind) )./get_power(answer.net.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
subplot(3,1,3)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.net.phasor - answer.map.cmphasor(ind) )./get_power(answer.net.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [100;100], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
%figure, plot(get_phase(answer.map.cphasor(ind)))
%figure, feather((answer.map.cphasor(ind))./answer.net.phasor)
%figure, feather((answer.map.cphasor(ind)-answer.net.phasor)./answer.net.phasor)

xmax = 20;
xmax = 125;
xmax = 50;
%ind = answer.map.ind0(:);
ind = answer.map.ind0(answer.map.fresnel_zone(answer.map.ind0(:)) < xmax);
  %figure, plot(answer.map.fresnel_zone(ind))
figure
subplot(3,1,1)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power(answer.map.cphasor(ind))./get_power(answer.composite.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  %plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  %ylim([-100,+350])
  set(gca, 'XGrid','on')
subplot(3,1,2)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.composite.phasor - answer.map.cphasor(ind) )./get_power(answer.composite.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
subplot(3,1,3)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.composite.phasor - answer.map.cphasor(ind) )./get_power(answer.composite.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [100;100], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
%figure, plot(get_phase(answer.map.cphasor(ind)))
%figure, feather((answer.map.cphasor(ind))./answer.net.phasor)
%figure, feather((answer.map.cphasor(ind)-answer.net.phasor)./answer.net.phasor)

xmax = 20;
xmax = 125;
xmax = 50;
%ind = answer.map.ind0(:);
ind = answer.map.ind0(answer.map.fresnel_zone(answer.map.ind0(:)) < xmax);
  %figure, plot(answer.map.fresnel_zone(ind))
figure
subplot(3,1,1)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power(answer.map.cphasor(ind))./get_power(answer.direct.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  %plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  %ylim([-100,+350])
  set(gca, 'XGrid','on')
subplot(3,1,2)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.direct.phasor + answer.map.cphasor(ind) )./get_power(answer.composite.phasor) - 100, ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [0;0], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
subplot(3,1,3)
  plot(2*answer.map.fresnel_zone(ind), ...
    100.*get_power( answer.direct.phasor + answer.map.cphasor(ind) )./get_power(answer.composite.phasor), ...
    '-k', 'LineWidth',2)
  xlim([0,xmax])
  %grid on
  hold on
  plot([0;xmax], [100;100], ':k')
  set(gca, 'XTick',0:1:xmax)
  set(gca, 'XGrid','on')
%figure, plot(get_phase(answer.map.cphasor(ind)))
%figure, feather((answer.map.cphasor(ind))./answer.net.phasor)
%figure, feather((answer.map.cphasor(ind)-answer.net.phasor)./answer.net.phasor)

%xmax = 20;
%xmax = 100;
%xmax = +Inf;
%%ind = answer.map.ind0(:);
%ind = answer.map.ind0(answer.map.fresnel_zone(answer.map.ind0(:)) < xmax);
%  %figure, plot(answer.map.fresnel_zone(ind))
%%%figure
%%%subplot(1,2,1)
%%%  plot(answer.map.cphasor(ind) ./ answer.net.phasor, '-k', 'LineWidth',2)
%%%  axis image
%%%  grid on
%%%subplot(1,2,2)
%%%  plot((answer.map.cphasor(ind) - answer.net.phasor) ./ answer.net.phasor, '-k', 'LineWidth',2)
%%%  axis image
%%%  grid on
%%figure
%%  hold on
%%  plot(answer.map.cphasor(ind) ./ answer.net.phasor, '-b', 'LineWidth',2)
%%  plot((answer.map.cphasor(ind) - answer.net.phasor) ./ answer.net.phasor, '-r', 'LineWidth',2)
%%  axis image
%%  grid on
%figure
%  plot((answer.map.cphasor(ind) - answer.net.phasor) ./ answer.net.phasor, '-k', 'LineWidth',1)
%  axis image
%  grid on
%  xlabel('Real')
%  ylabel('Imag')

  

%xmax = 200;
%%xmax = 50;
%%ind = answer.map.ind0c(:);
%%ind = answer.map.ind0c(answer.map.fresnel_zone(answer.map.ind0b(:)) < xmax);
%ind = answer.map.ind0c(1:xmax);
%  %figure, plot(answer.map.fresnel_zone(ind))
%figure
%subplot(4,1,1)
%  plot(...
%    ...%2*abs(answer.map.(ind)), ...
%    100.*(get_power(answer.map.cphasorc(ind)) - get_power(answer.net.phasor))./get_power(answer.net.phasor), ...
%    '-k', 'LineWidth',2)
%  xlim([0,xmax])
%  %grid on
%  hold on
%  plot([0;xmax], [0;0], ':k')
%  set(gca, 'XTick',0:1:xmax)
%  set(gca, 'XTickLabel',[])
%  ylim([-100,+300])
%  set(gca, 'XGrid','on')
%subplot(4,1,2)
%  plot(2*answer.map.fresnel_zone(ind), ...
%    ...%100.*(get_power(answer.direct.phasor + answer.map.cphasor(ind)) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor), ...
%    100.*(get_power(answer.direct.phasor + answer.map.cphasor(ind)) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor), ...
%    '-k', 'LineWidth',2)
%  xlim([0,xmax])
%  %grid on
%  hold on
%  plot([0;xmax], [0;0], ':k')
%  set(gca, 'XTick',0:1:xmax)
%  set(gca, 'XTickLabel',[])
%  set(gca, 'XGrid','on')
%  ylim([-100,+100])
%subplot(4,1,3)
%  plot(2*answer.map.fresnel_zone(ind), ...
%    ...%100.*(get_power(answer.net.phasor - answer.map.cphasor(ind)))./get_power(answer.net.phasor), ...
%    100.*(get_power(answer.map.cphasor(ind) - answer.net.phasor))./get_power(answer.net.phasor), ...
%    '-k', 'LineWidth',2)
%  xlim([0,xmax])
%  %grid on
%  hold on
%  plot([0;xmax], [100;100], ':k')
%  set(gca, 'XTick',0:1:xmax)
%  set(gca, 'XTickLabel',[])
%  set(gca, 'XGrid','on')
%  ylim([65,+100])
%subplot(4,1,4)
%  plot(2*answer.map.fresnel_zone(ind), ...
%    100.*(get_power(answer.direct.phasor + answer.map.cphasor(ind) - answer.composite.phasor))./get_power(answer.composite.phasor), ...
%    ...%100.*(get_power(answer.direct.phasor + answer.map.cphasor(ind)) - get_power(answer.composite.phasor))./get_power(answer.composite.phasor), ...
%    '-k', 'LineWidth',2)
%  xlim([0,xmax])
%  %grid on
%  hold on
%  %plot([0;xmax], [100;100], ':k')
%  set(gca, 'XTick',0:1:xmax)
%  set(gca, 'XGrid','on')
%  ylim([13,21])
%%figure, plot(get_phase(answer.map.cphasor(ind)))
%%figure, feather((answer.map.cphasor(ind))./answer.net.phasor)
%%figure, feather((answer.map.cphasor(ind)-answer.net.phasor)./answer.net.phasor)
  

plotpo(answer, @(map) 100*(get_power(map.cphasorb) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*get_power(map.cphasorb - answer.net.phasor)./get_power(answer.net.phasor), 'jet')

plotpo(answer, @(map) 100*(get_power(map.cphasorc) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*get_power(map.cphasorc - answer.net.phasor)./get_power(answer.net.phasor), 'jet')

answer.map.Dcphasor = answer.net.phasor - answer.map.cphasor;
%answer.map.Dcphasor = answer.map.cphasor -  answer.net.phasor;
plotpo(answer, @(map) 100*get_power(map.Dcphasor)./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.Dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')
plotpo2(answer, @(map) 100*(get_power(answer.net.phasor - map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))
plotpo2(answer, @(map) 100*(get_power(map.cphasor - answer.net.phasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))


answer.map.dcphasor = answer.map.Dcphasor .* (answer.map.ind1 ./ answer.num_elements);
plotpo(answer, @(map) answer.map.ind1, 'jet')
plotpo(answer, @(map) 100*get_power(map.dcphasor)./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')
plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - map.dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')
plotpo2(answer, @(map) 100*get_power(map.dcphasor)./get_power(answer.net.phasor))
plotpo2(answer, @(map) 100*(get_power(answer.net.phasor - map.dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))
plotpo2(answer, @(map) 100*abs(get_power(answer.net.phasor - map.dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))


plotpo(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), 'jet')  % how cum phasor converges to net phasor, in terms of power
plotpo(answer, @(map) 100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), 'jet')  % how cum phasor converges to net phasor, in terms of power
xlim([-1,+1]*10)
ylim([-1,+1]*10)
plotpo(answer, @(map) setel(100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), (answer.map.fresnel_zone > 19.33), NaN), 'jet')  % how cum phasor converges to net phasor, in terms of power
  %set(gco, 'AlphaData',(answer.map.fresnel_zone < 19.33));
  colormap(setel(jet, 64*[0,1,2]+1, 1))  
  xlim([-1,+1]*25)
  ylim([-1,+1]*25)
  xlim([-1,+1]*10)
  ylim([-1,+1]*10)
plotpo2(answer, @(map) setel(100*get_power(map.cphasor - answer.net.phasor)./get_power(answer.net.phasor), (answer.map.fresnel_zone > 19.33), NaN))
  xlim([-1,+1]*10)
  ylim([-1,+1]*10)
  

plotpo(answer, @(map) abs(answer.map.coh), 'jet'),  set(gca, 'CLim',[0,1])
plotpo(answer, @(map) abs(answer.map.coh), 'gray'),  set(gca, 'CLim',[0,1])
plotpo(answer, @(map) abs(answer.map.coh), 'flipud(gray)'),  set(gca, 'CLim',[0,1])


%answer.map.Dcphasor = answer.map.cphasor -  answer.net.phasor;
plotpo(answer, @(map) 100*get_power(map.Dcphasor)./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.Dcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')
plotpo2(answer, @(map) 100*(get_power(answer.net.phasor - map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))
plotpo2(answer, @(map) 100*(get_power(map.cphasor - answer.net.phasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor))


plotpo(answer, @(map) 100*get_power(map.mphasor)./get_power(answer.net.phasor), 'jet')  % if I were to image only one 1-m^2 portion
plotpo2(answer, @(map) 100*get_power(map.mphasor)./get_power(answer.net.phasor))
%plotpo(answer, @(map) 100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.mphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion
plotpo2(answer, @(map) 100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor)-100)  % if I were to NOT image only one 1-m^2 portion
%plotpo2(answer, @(map) 100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor))  % if I were to NOT image only one 1-m^2 portion
%plotpo(answer, @(map) 100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor)-100, 'bwr')  % if I were to NOT image only one 1-m^2 portion
plotpo(answer, @(map) abs(100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor)-100), 'jet')  % if I were to NOT image only one 1-m^2 portion
plotpo2(answer, @(map) abs(100*get_power(answer.net.phasor - map.mphasor)./get_power(answer.net.phasor)-100))  % if I were to NOT image only one 1-m^2 portion
plotpo(answer, @(map) 100*(get_power(answer.net.phasor - map.mphasor./answer.dA.*answer.flt_area) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion
plotpo(answer, @(map) 100*abs(get_power(answer.net.phasor - map.mphasor./answer.dA.*answer.flt_area) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion


answer.map.mcphasor = answer.filterit(answer.map.cphasor);
plotpo(answer, @(ignore) 100*(get_power(answer.map.mcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')
plotpo(answer, @(ignore) 100*abs(get_power(answer.map.mcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')
plotpo(answer, @(ignore) 100*(get_power(answer.net.phasor - answer.map.mcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')
plotpo(answer, @(ignore) 100*(get_power(answer.net.phasor - answer.map.mcphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'jet')


plotpo4(answer, @(map) 100*get_power(map.mphasor - answer.net.phasor)./get_power(answer.net.phasor), @(map) map.mphasor - answer.net.phasor, 75, (1e+11)/2)
%answer.map.real = real(answer.map.mphasor - answer.net.phasor);
%  answer.map.imag = imag(answer.map.mphasor - answer.net.phasor);
%  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/2)
%  plotpo3(answer, 75, 1/(abs(answer.net.phasor))*1/2, true)
answer.map.real = real(answer.map.mphasor);
  answer.map.imag = imag(answer.map.mphasor);
  plotpo3(answer, 75, 1/(abs(answer.net.phasor)/answer.num_elements)*1e-2)
  plotpo3(answer, 75, 1/(abs(answer.net.phasor)/answer.num_elements)*1e-2, true)

return

%plotpo(answer, @(map)map.dist_incid, 'jet')
%plotpo(answer, @(map)map.dist_incid-answer.dist_sat, 'jet')
%plotpo2(answer, @(map)map.dist_incid-answer.dist_sat)
%plotpo(answer, @(map)map.dist_scatt, 'jet')
%plotpo2(answer, @(map)map.dist_scatt)
%plotpo(answer, @(map)map.dist_excess, 'jet')
%plotpo(answer, @(map)1./map.dist_excess, 'jet')
%plotpo(answer, @(map)answer.dist_sat./(map.dist_scatt.*map.dist_incid), 'jet')
%plotpo(answer, @(map)1./(map.dist_scatt.*map.dist_incid), 'jet')
%plotpo(answer, @(map)1./(map.dist_scatt), 'jet')
%plotpo2(answer, @(map)map.dist_excess)
%plotpo(answer, @(map)map.dist_incid-answer.dist_sat+map.dist_scatt, 'jet')
%plotpo2(answer, @(map)map.dist_incid-answer.dist_sat+map.dist_scatt)

plotpo(answer, @(map)map.K1, 'jet')
plotpo(answer, @(map)map.K2, 'jet')
plotpo(answer, @(map)100*map.K2./map.K1, 'jet')

plotpo(answer, @(map)abs(map.F), 'jet')
plotpo(answer, @(map)get_phase(map.F), 'hsv')

plotpo(answer, @(map) get_power(map.phasor), 'jet')
plotpo(answer, @(map) get_phase(map.phasor), 'hsv')

plotpo(answer, @(map) get_phase(map.X), 'hsv')

plotpo(answer, @(map)map.phase_unwrapped, 'jet')
plotpo(answer, @(map)map.phase_grad, 'jet')
plotpo2(answer, @(map)map.phase_grad)

plotpo(answer, @(map) map.fresnel_zone_number, 'jet'), set(gca, 'CLim',[0,10])


n = 10;
n = 25;
n = 50;
elev_all = get_elev_regular_in_sine(n, 5, 30, false, false)
azim_all = repmat(0, [n,1]);

%[snr_db, answers] = calc_diffraction_series2 (elev_all, azim_all, ant, opt, {'*'});
[snr_db, answers] = calc_diffraction_series2 (elev_all, azim_all, ant, opt, {'cphasor','fresnel_zone', 'mphasor', 'cmphasor', 'ind0', 'ind1', 'coh'});

figure
for i=1:length(answers)
  disp(elev_all(i))
  %temp = 100*abs(get_power(answers(i).composite.phasor - answers(i).map.mphasor) ./ get_power(answers(i).composite.phasor) - 1);
  %temp = 100*abs(get_power(answers(i).composite.phasor - answers(i).net.phasor + answers(i).map.mphasor) ./ get_power(answers(i).composite.phasor) - 1);
  %temp = 100*get_power(answers(i).map.mphasor)./get_power(answers(i).composite.phasor);
  %temp = abs(answers(i).map.coh);
  temp = get_power(answers(i).map.mphasor)./get_power(answers(i).composite.phasor) .* abs(answers(i).map.coh);
  %temp = get_phase(answers(i).map.coh);
  imagesc(answers(i).map.x_domain, answers(i).map.y_domain, temp)
  set(gca, 'YDir','normal')
  %set(gca, 'CLim',[0,1e-4])
  axis image
  colorbar
  pause
end

xmax = 50;
figure
hold on
for i=length(answers):-1:1
  disp(elev_all(i))
  idx = (answers(i).map.fresnel_zone < xmax);
  idx = idx & (answers(i).map.fresnel_zone < min(answers(i).map.fresnel_zone(get_border_ind(answers(i).map.fresnel_zone))));
  ind = answers(i).map.ind0(idx);
  plot(answers(i).map.fresnel_zone(ind), ...
    100.*get_power( answers(i).net.phasor - answers(i).map.cphasor(ind) )./get_power(answers(i).net.phasor) - 100, ...
    '-k', 'LineWidth',2)
  pause
end
xlim([0,xmax])
%grid on
hold on
plot([0;xmax], [0;0], ':k')
set(gca, 'XTick',0:1:xmax)
set(gca, 'XGrid','on')

%fz = [1, 5, 10, 15];
fz = 1:10;
figure
for j=numel(fz):-1:1
for i=length(answers):-1:1
  disp(elev_all(i))
  imagesc(answers(i).map.x_domain, answers(i).map.y_domain, (answers(i).map.fresnel_zone < fz(j)));
  set(gca, 'YDir','normal')
  axis image
  pause
end
end

figure
colorbar
for i=length(answers):-1:1
  disp(elev_all(i))
  temp = 100*abs(get_power(answers(i).composite.phasor - answers(i).map.cmphasor) - get_power(answers(i).composite.phasor) ) ./ get_power(answers(i).composite.phasor);
  temp(answers(i).map.fresnel_zone > min(answers(i).map.fresnel_zone(get_border_ind(answers(i).map.fresnel_zone)))) = NaN;
  imagesc(answers(i).map.x_domain, answers(i).map.y_domain, temp);
  set(gco, 'AlphaData',~isnan(temp))
  set(gca, 'Color','w')
  set(gca, 'YDir','normal')
  axis image
  colorbar
  pause
end

fz = 0:0.1:1;
fz = 1:0.1:2;
fz = 0:2:10;
%fz = 1:2:10;
%fz = 0:0.5:10;
temp = [];
for i=1:length(answers)
for j=1:numel(fz)
  ind = argmin(abs(answers(i).map.fresnel_zone(:) - fz(j)));
  temp(i,j) = get_power(answers(i).composite.phasor - answers(i).net.phasor + answers(i).map.cphasor(ind));
end
end
figure
hold on
%for j=1:numel(fz)
for j=numel(fz):-1:1
  h(j)=plot(elev_all, temp(:,j), '-', 'Color',[1 1 1]*(0.9-0.8*(j-1)/(numel(fz)-1)), 'LineWidth',3);
end
grid on
xlabel('Elevation angle (degrees)')
ylabel('Composite power (W)')
h=legend(h, num2str(reshape(fz,[],1), '%.1f'), 'Location','SouthEast');
legendtitle(h, 'Fresnel zone #')

fz = 2:0.1:3;
%fz = 1:0.1:2;
%fz = 0:0.1:1;
fz = 0:2:10;
fz = 1:2:10;
fz = 0:0.5:10;
temp = [];
for i=1:length(answers)
for j=1:numel(fz)
  ind = argmin(abs(answers(i).map.fresnel_zone(:) - fz(j)));
  temp(i,j) = get_power(answers(i).composite.phasor - answers(i).net.phasor + answers(i).map.cmphasor(ind));
end
end
figure
hold on
%for j=1:numel(fz)
for j=numel(fz):-1:1
  h(j)=plot(elev_all, temp(:,j), '-', 'Color',[1 1 1]*(0.9-0.8*(j-1)/(numel(fz)-1)), 'LineWidth',3);
end
grid on
xlabel('Elevation angle (degrees)')
ylabel('Composite power (W)')
h=legend(h, num2str(reshape(fz,[],1), '%.1f'), 'Location','SouthEast');
legendtitle(h, 'Fresnel zone #')



%for k=4
for k=1:4
clear M
for i=1:length(answers)
  answer = answers(i);
  switch k
  case 1, plotpo(answer, @(ignore) 100*(get_power(answer.composite.phasor - answer.map.phasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'bwr')  % if I were to NOT image only one element, in interferometric mode
  case 2, plotpo(answer, @(ignore) 100*(get_power(answer.map.cphasor) - get_power(answer.net.phasor))./get_power(answer.net.phasor), 'bwr')  % how cum phasor changes in power
  case 3, plotpo(answer, @(ignore) 100*(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'bwr')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
  case 4, plotpo(answer, @(ignore) 100*abs(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
  end
  title(sprintf('elev=%.3f�',elev(ind(i))))
  maximize(gcf)
  delete(colorbar())
  M(i) = getframe(gcf);
  close(gcf)
  %pause
end
movie2avi(M,num2str(k), 'fps',12/2, 'quality',100);
%figure, maximize(gcf), movie(gcf,M,-30,12/2,[0 0 0 0])
end





n = 25;
n = 50;
n = 10;
elev_all = get_elev_regular_in_sine(n, 5, 30, false, false)
elev_all = get_elev_regular_in_sine(n, 5, 30, true, false)
azim_all = repmat(0, [n,1]);
[snr_db, answers] = calc_diffraction_series2 (elev_all, azim_all, ant, opt, {'*'});
%[snr_db, answers] = calc_diffraction_series2 (elev_all, azim_all, ant, opt, {'cphasor','fresnel_zone', 'mphasor', 'cmphasor', 'ind0', 'ind1', 'coh'});

l = 1;
l = 6;
l = 8;
l = 5;
l = 2;
clear M
for k=1:length(answers)
  fprintf('k=%d\n', k)
  answer = answers(k);
  elev = elev_all(k);
  azim = azim_all(k);

  height2 = ref.pos_ant(3);
  pos_refl = get_specular_reflection (height2, elev, azim);
  fzn = [0.5, 1, 1.5];
  clear fz
  for i=1:numel(fzn)
    fz(i) = get_fresnel_zone (height2, elev, azim, opt.wavelength, fzn(i), [], 1e-2);
  end
  
  switch l
  case 1
    plotpo(answer, @(map) abs(answer.map.mphasor), 'jet')
  case 2
    %plotpo(answer, @(map) get_power(answer.map.mphasor), 'jet')
    temp = get_power(answer.map.mphasor);
    plotpo(answer, @(map) 100 * temp ./ max(max(temp)), 'jet')
    set(gca, 'CLim',[0,100])
  case 3
    plotpo(answer, @(map) get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor), 'jet')
  case 4
    plotpo(answer, @(map) get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor) .* abs(answer.map.coh), 'jet')
  case 5
    temp = get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor) .* abs(answer.map.coh);
      plotpo(answer, @(map) 100 * temp ./ max(max(temp)), 'jet')
    set(gca, 'CLim',[0,100])
  case 6
    plotpo(answer, @(map) get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor) .* real(answer.map.coh), 'bwr')
  case 7
    plotpo(answer, @(map) get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor) .* abs(real(answer.map.coh)), 'jet')
  case 8
    temp = get_power(answer.map.mphasor) + 2 * abs(answer.direct.phasor) * abs(answer.map.mphasor) .* abs(real(answer.map.coh));
      plotpo(answer, @(map) 100*temp./max(max(temp)), 'jet')
    set(gca, 'CLim',[0,100])
  end
  
  hold on
  plot(0, 0, 'wo', 'MarkerSize',7, 'MarkerFaceColor','w')
  %plot(0, 0, 'ko', 'MarkerSize',8, 'LineWidth',2)
  plot(pos_refl(2), pos_refl(1), 'w+', 'MarkerSize',12, 'LineWidth',4)
  plot(pos_refl(2), pos_refl(1), 'k+', 'MarkerSize',8, 'LineWidth',2)
  for i=1:numel(fzn)
    plot(fz(i).x, fz(i).y, 'w-', 'LineWidth',4)
    plot(fz(i).x, fz(i).y, 'k-', 'LineWidth',2)
  end
  set(gca, 'XTick',lim(1):5:lim(2))
  set(gca, 'YTick',lim(3):5:lim(4))
  
  %title(sprintf('elev=%.3f�',elev))
  title(sprintf('elev=%.0f�',elev), 'FontSize',14)
  maximize(gcf)
  %delete(colorbar())
  M(k) = getframe(gcf);
  pause
  close(gcf)
end
movie2avi(M, sprintf('untitled%d', l), 'fps',12/2, 'quality',100);
figure, maximize(gcf), movie(gcf,M,-30,12/2,[0 -275 0 0])

%%%%%%%%%%%%%%%%%%%%%%%55

sett.ref.height_ant = height;
[sat, sfc, ant, ref, opt2] = snr_fwd_setup (sett);
opt = structmerge(opt, opt2);
opt.material_bottom = 'wet ground';
answer1 = calc_diffraction2 (elev, azim, ant, opt);
answer1 = calc_diffraction_aux (answer1);

opt.material_bottom = 'dry ground';
answer2 = calc_diffraction2 (elev, azim, ant, opt);
answer2 = calc_diffraction_aux (answer2);

%sett.ref.height_ant = height + 1e-2;
%[sat, sfc, ant, ref, opt2] = snr_fwd_setup (sett);
%opt = structmerge(opt, opt2);
%opt.material_bottom = 'wet ground';
%answer2 = calc_diffraction2 (elev, azim, ant, opt);
%answer2 = calc_diffraction_aux (answer2);


plotpo(answer, @(map) 100*abs(get_power(answer1.net.phasor - answer1.map.mphasor + answer2.map.mphasor) - get_power(answer1.net.phasor) ) ./ get_power(answer1.net.phasor), 'jet')
plotpo(answer, @(map) 100*abs(get_power(answer1.net.phasor - answer1.map.phasor + answer2.map.phasor) - get_power(answer1.net.phasor) ) ./ get_power(answer1.net.phasor), 'jet')


%%%%%%%%%%%%%%%%%%%%%%%55

answer = calc_diffraction2 (elev, azim, ant, opt);
answer = calc_diffraction_aux (answer);
tol = 0.1;
step2 = [];
step2 = 5;
%step2 = 1;

lim2 = [];
lim2 = [];
%lim2 = 5;
lim2 = [-5, +5,  0, 15];  step2 = 0.5;
lim2 = [-3, +3,  0, 10];  step2 = 0.1;
flt_radius = [];
do_plot_it = true;
do_plot_it = false;
answer2 = calc_diffraction_cross_coherence (answer, tol, step2, lim2, flt_radius, do_plot_it);
  %clear calc_diffraction_cross_coherence;
  %[ccoh, x_domain2, y_domain2] = calc_diffraction_cross_coherence (answer, tol, step2, lim2, flt_radius, do_plot_it);
  %profile -detail builtin on
  %[ccoh, x_domain2, y_domain2] = calc_diffraction_cross_coherence (answer, tol, step2, lim2, flt_radius, do_plot_it);
  %profile viewer
disp(roundn(cellfun(@(ratio) 100*nnz(ratio)/numel(ratio), ccoh), -1));

plotpo(answer, @(map) get_power(answer.map.mphasor), 'jet')
%plotpo(answer2, @(map) get_power(answer2.map.phasor), 'jet', [], 'map')
plotpo(answer2, @(map2) real(answer2.map2.interfcontrib), 'bwr', [], 'map2')
plotpo(answer2, @(map2) get_phase(answer2.map2.interfcontrib), 'hsv', [], 'map2')
plotpo(answer2, @(map2) abs(real(answer2.map2.interfcontrib)), 'jet', [], 'map2')
plotpo(answer2, @(map2) 100*abs(real(answer2.map2.interfcontrib)) ./ get_power(answer.composite.phasor), 'jet', [], 'map2')

plotpo(answer, @(map) 100*abs(get_power(answer.composite.phasor - answer.map.mphasor) - get_power(answer.composite.phasor) ) ./ get_power(answer.composite.phasor), 'jet')  % if I were to NOT image only one 1-m^2 portion, in interferometric mode
  xlim(answer2.x_lim)
  ylim(answer2.y_lim)
  cl = get(gca, 'CLim');
plotpo(answer2, @(map2) 100*abs(real(answer2.map2.interfcontrib)) ./ get_power(answer.composite.phasor), 'jet', [], 'map2')
  set(gca, 'CLim',cl)


%%%%%%%%%%%

n = 10;
n = 25;
%n = 50;
%n = 100;
elev_all = get_elev_regular_in_sine(n, 80, 90, false, false)
%elev_all = get_elev_regular_in_sine(n, 45, 60, false, false)
elev_all = get_elev_regular_in_sine(n, 10, 20, false, false)
azim_all = repmat(0, [n,1]);

lim = [-2.5,+2.5, -5,+75];  step = 0.0125;
lim = [-5,+5, -5,+75];  step = 0.025;
lim = [-3.5,+3.5, -5,+75];  step = 0.02;
%lim = [-3.5,+3.5, -5,+100];  step = 0.02;
%lim = [-5,+5, -5,+100];  step = 0.02;
%lim = [-15,+15, -5,+50];  step = 0.025;
%lim = [-10,+10, -10,+10];  step = 0.02;
%lim = [-5,+5, -5,+35];  step = 0.015;
sett = snr_fwd_settings();
sett.sat.elev = elev_all;
sett.sat.azim = azim_all;
[sat, sfc, ant, ref, opt] = snr_fwd_setup (sett);
[go_snr_db, go_answers, go_carrier_error, go_code_error] = snr_fwd_run (sat, sfc, ant, ref, opt);
figure
  subplot(2,1,1),  plot(elev_all, go_snr_db)
  subplot(2,1,2),  plot(elev_all, go_code_error*100)

opt.patch_extent = [];
opt.lim = lim;
opt.step = step;
opt.height_std = sett.sfc.height_std;
opt.material_top = sfc.material_top;
opt.material_bottom = sfc.material_bottom;
opt.cdma.disable = false;  opt.cdma.assume_zero = false;
opt.cdma.disable = false;  opt.cdma.assume_zero = false;  opt.cdma.iterate = true;
%opt.cdma.disable = false;  opt.cdma.assume_zero = false;  opt.cdma.iterate = false;

%[snr_db, answers] = calc_diffraction_series2 (elev_all, azim_all, ant, opt, {'*'});
[snr_db, answers, carrier_error, code_error] = calc_diffraction_series (elev_all, azim_all, ant, opt);

figure
subplot(2,1,1)
  hold on
  plot(elev_all, snr_db, '-k')
  plot(elev_all, go_snr_db, '-r')
subplot(2,1,2)
  hold on
  plot(elev_all, code_error*100, '-k')
  plot(elev_all, go_code_error*100, '-r')


%sett = snr_fwd_settings();
[sat, sfc, ant, ref, opt] = snr_fwd_setup (sett);
snr_db = snr_fwd_run (sat, sfc, ant, ref, opt);
