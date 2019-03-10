% Effect of surface random roughness on GPS multipath errors. Surface
% height standard deviation values equal to 0, 25, and 35 cm are shown in
% red, green, and blue, respectively
%
% Fig. 4 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper ();

%%
%num_cases = 5;
num_cases = 3;
roughness_lim = [10e-2 35e-2];
roughness_domain = linspace(roughness_lim(1), roughness_lim(2), num_cases)';
%roughness_domain = linspace(roughness_lim(1)^2, roughness_lim(2)^2, num_cases)'.^(1/2);
siz = [num_cases 1];

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.sfc.height_std = roughness_domain(k);   end
setup0 = snr_setup(sett0);
setup  = cell_snr_resetup(sett, setup0);
result = cell_snr_fwd(setup);

%%
for k=1:num_cases
  temp = {result{k}.phasor_direct, result{k}.phasor_reflected, true, false, result{k}.phasor_direct};
 %temp = {result{k}.phasor_direct, result{k}.phasor_reflected, false, false};  % WRONG! scales are not comparable!
  result{k}.mp_modul = get_multipath_modulation (temp{:});
end

%%
figure
if sett0.opt.max_plot,  maximize();  end
h = [];
for k=1:num_cases
  mysubplot(3,1,1)
    hold on
    %h(k,1)=myplot(setup{k}.sat.elev, result{k}.snr_db, '-k', 'LineWidth',2);
    %ylabel('SNR (dB)')
    h(k,1)=myplot(setup{k}.sat.elev, result{k}.mp_modul, '-k', 'LineWidth',2);
    ylabel('Power (W/W)')
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
assert(num_cases == 3)
set(h(1,:), 'Color','r')
set(h(2,:), 'Color','g')
set(h(3,:), 'Color','b')
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
mysubplot(3,1,2),  ylim([-1, +1]*getel(ylim(),2))
temp = num2str(roughness_domain(:)*100, '%.0f cm');
%mysubplot(3,1,3),  myplabel(h(:,3), temp, [8.5 0.5])
mysubplot(3,1,2),  h=legend(h(:,2), temp, 'Location','East');  %legendtitle(h, '(cm)')
mysaveas('figA4')
