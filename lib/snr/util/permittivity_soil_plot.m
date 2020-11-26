function permittivity_soil_plot ()

% Remake Fig 6-a in Hallikainen et al. (1985):
% Hallikainen, M.T.; Ulaby, F.T.; Dobson, M.C.; El-Rayes, M.A.; Lil-Kun Wu;
% "Microwave Dielectric Behavior of Wet Soil-Part 1: Empirical Models and
% Experimental Observations," Geoscience and Remote Sensing, IEEE
% Transactions on , vol.GE-23, no.1, pp.25-34, Jan. 1985, doi:
% 10.1109/TGRS.1985.289497

perm = permittivity_soil_setup ();

n = numel(perm.real);
hr = NaN(n,1);
hi = NaN(n,1);
t = cell(n,1);
figure
hold on
for i=1:n
  hr(i)=plot(perm.real(i).moisture, perm.real(i).value, '-');
  t{i} = perm.real(i).type;
end
for i=1:5
  hi(i)=plot(perm.imag(i).moisture, perm.imag(i).value, '--');
end
h=legend(hr, t, 'Location','west', 'EdgeColor','none');
  legendTitle(h, 'Soil type', 'FontWeight','normal');
%legend([hr(1) hi(1)], {'Real','Imag.'}, 'Location','west')
grid on
xlabel('Volumetric soil moisture (m^3/m^3)')
ylabel('Relative permittivity')
annotation('textbox',[0.82 0.75 0.05 0.13],...
  'String','Real',...
  'FitBoxToText','off',...
  'EdgeColor','none');
annotation('textbox',[0.82 0.15 0.05 0.13],...
  'String','Imag.',...
  'FitBoxToText','off',...
  'EdgeColor','none');

end
