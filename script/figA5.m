% Effect of surface material composition on GPS multipath errors
% 
% Fig. 5 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper ();
%sett0.ant.polar_phase = 0;

%%
material = {'dry ground', 'wet ground', 'freshwater', 'copper'};
num_cases = numel(material);
siz = [num_cases 1];

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.sfc.material_bottom = material(k);   end
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
assert(num_cases == 4)
set(h(1,:), 'Color','r')
set(h(2,:), 'Color','g')
set(h(3,:), 'Color','b')
set(h(4,:), 'Color','k')
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
%mysubplot(3,1,3),  myplabel(h(:,3), material, [8.5 0.5])
mysubplot(3,1,2),  h=legend(h(:,2), material, 'Location','East');  %legendtitle(h, '(cm)')
%mysaveas(['15b-' num2str(sett0.ant.polar_phase) '-' num2str(sett0.sat.elev_lim(2))])
mysaveas('figA5')
