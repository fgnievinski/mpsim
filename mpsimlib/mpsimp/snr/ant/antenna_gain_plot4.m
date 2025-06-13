function antenna_gain_plot4 (data_rhcp, data_lhcp)

if ~strcmpi(data_rhcp.type, 'gain'),  return;  end

figure
hold on
plot(data_rhcp.profile.ang, data_rhcp.profile.final, '.-b')
plot(data_lhcp.profile.ang, data_lhcp.profile.final, '.-r')
xlabel('Boresight angle (degrees)')
ylabel(sprintf('%s (%s)', data_rhcp.profile.final_label, data_rhcp.profile.final_units))
grid on
