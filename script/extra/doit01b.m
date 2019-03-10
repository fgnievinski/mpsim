sett = snr_settings();
setup = snr_setup (sett);
result = snr_fwd (setup);

%%
e = result.sat.elev;
F_x = result.reflected.phasor_fresnelcoeff_cross;
F_s = result.reflected.phasor_fresnelcoeff_same;
temp = {'cross','same'};
figure
subplot(2,1,1)
  hold on
  plotsin(e, abs(F_x), '.-b')
  plotsin(e, abs(F_s), '.-r')
  xlimsin(result.sat.elev([1 end]))
  grid on
  ylabel('Magnitude (V/V)')
  legend(temp, 'Location','East')
subplot(2,1,2)
  hold on
  plotsin(e, get_phase(F_x), '.-b')
  plotsin(e, get_phase(F_s), '.-r')
  xlimsin(result.sat.elev([1 end]))
  grid on
  ylabel('Phase (degrees)')
  legend(temp, 'Location','East')
mtit('Fresnel reflection coefficients')

%%
moist_min = 0.25;
moist_max = 0.75;
moist = linspace(moist_min, moist_max)';
material = struct('name','soil', 'moisture',moist);
perm = get_permittivity(material);
figure
  hold on
  plot(moist, real(perm), '.-r')
  plot(moist, imag(perm), 'x-b')
  ylabel('Permittivity')
  xlabel('Moisture')
  xlim([moist_min moist_max])
  grid on
  legend({'Real','Imag.'}, 'Location','East')
  title('Soil')
