function antenna_gain_plot5 (data_rhcp, data_lhcp, type)
if (nargin < 3) || isempty(type),  type = 1;  end

R = data_rhcp.densemap.final_grid;
L = data_lhcp.densemap.final_grid;
A = R + L;
B = R - L;
in = struct('R',R, 'L',L, 'A',A, 'B',B);
%data = f(in);

switch type
case 1
    f2 = @(in) (in.L./in.R);
    f = @(in) (f2(in) - 1);
    fi = @(in) (in + 1);
    tit = sprintf('Antenna polarimetric magnitude (V/V)');
    %colorbar_which = @colormap_bwr_it;
    colorbar_which = @() colormbl(dkbluered, [], [], [], 'tight');
    max_val = +2.0;
case 1.1
    f2 = @(in) decibel_amplitude(in.L./in.R);
    f = @(in) f2(in);
    fi = @(in) in;
    tit = sprintf('Antenna polarimetric ratio (dB)');
    %colorbar_which = @colormap_bwr_it;
    colorbar_which = @colormbl;
    max_val = [];
case 2
    f2 = @(in) (abs(in.B)./in.A);
    f = @(in) f2(in);
    tit = sprintf('Antenna polarization ellipticity (%%)');
    colorbar_which = @colorbar;
    max_val = 1.0;
end

%%
temp = f(in);
figure
  imagesc(...
    data_lhcp.densemap.azim_domain, ...
    data_lhcp.densemap.elev_domain, ...
    temp)
  xlabel('Azimuth (degrees)')
  ylabel('Elevation angle (degrees)')
  set(gca, 'YDir','normal')
  set(gca, 'XTick',0:90:360)
  set(gca, 'YTick',-90:30:+90)
  h = colorbar_which();
  %title(h, tit)
  ylabel(h, tit)
  %set(h, 'YTickLabel',num2str(reshape(myflip(get(h, 'YTick')), [],1)))
  title(data_lhcp.filename, 'Interpreter','none')
  %set(gca, 'CLim',cl)
  grid on

%%
if isempty(max_val),  return;  end
ind1 = argmin(abs(data_lhcp.densemap.azim_domain - 0));
ind2 = argmin(abs(data_lhcp.densemap.azim_domain - 180));
temp = f2(in);
temp = horzcat(...
  temp(:,ind1)', ...
  fliplr(temp(:,ind2)') ...
);
ang = horzcat(...
  fliplr(90 - data_lhcp.densemap.elev_domain), ...
  fliplr(180 + 90 - data_lhcp.densemap.elev_domain) ...
);
ang = -(ang - 180);
%whos temp ang
%figure, plot(ang, '.-k')
%figure, plot(temp, '.-k')
%figure, plot(ang, temp, '.-k')
%keyboard
figure
pp(ang*pi/180, temp, ...
    'RingStep',0.5, ...
    ...#'RingTickLabel',temp4, ...
    'ThetaDirection','cw', ...
    'ThetaStartAngle',+270, ...
    'MaxValue',max_val, ...
    'CentreValue',0, ...
    'Marker','.', ...
    'LineStyle','-', ...
    'LineColor','k', ...
    'LineWidth',2 ...
)
axis equal
title(strrep(func2str(f), 'in.',''), 'Interpreter','none')

end

