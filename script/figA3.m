% Effect of reflector height on GPS multipath errors.  Reflector height
% values equal to 1/2, 1, and 2 m are shown in red, blue, and green,
% respectively
% 
% Fig. 3 in Nievinski, F.G. and Larson, K.M. (2014), "Forward modeling of
% GPS multipath for near-surface reflectometry and positioning
% applications", GPS Solut (in press), doi:10.1007/s10291-013-0331-y

sett0 = snr_settings_paper();

%%
%height_domain = [0.1, 1, 10];
height_domain = [0.5, 1, 2];
num_cases = numel(height_domain);
siz = [num_cases 1];

%%
sett = repmat({sett0}, siz);
for k=1:num_cases,  sett{k}.ref.height_ant = height_domain(k);   end
setup0 = snr_setup(sett0);
setup  = snr_resetup(sett, setup0);
result = snr_fwd(setup);

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
%for k=1:num_cases
for k=num_cases:-1:1
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
set(h(2,:), 'Color','b')
set(h(3,:), 'Color','g')
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
temp = num2str(height_domain(:), '%.1f m');
%mysubplot(3,1,3),  myplabel(h(:,3), temp, [8.5 0.5])
mysubplot(3,1,2),  h=legend(h(:,2), temp, 'Location','SouthEast');  %legendtitle(h, '(cm)')
mysubplot(3,1,2),  set(gca(), 'YTickLabel',strcats(' ', get(gca(), 'YTickLabel')))  % align y labels.
mysubplot(3,1,3),  set(gca(), 'YTickLabel',strcats(' ', get(gca(), 'YTickLabel')))  % align y labels.
%mysaveas(sprintf('%d-%g-%g', 23, height_domain(1), height_domain(end)))
mysaveas('figA3')
