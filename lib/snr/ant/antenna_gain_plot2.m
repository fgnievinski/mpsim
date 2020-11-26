function antenna_gain_plot2 (data_rhcp, data_lhcp, dir, maxval, type, ignore_lhcp)
if (nargin < 3),  dir = [];  end
if (nargin < 4),  maxval = [];  end
if (nargin < 5) || isempty(type),  type = [1 2];  end
if (nargin < 6) || isempty(ignore_lhcp),  ignore_lhcp = false;  end

data = {data_rhcp, data_lhcp};
%for i=1:2  % for each offset-gain, non-offset-gain.
%for i=1
for i=type
  figure    
  for j=1:2  % for each RHCP, LHCP
      if (j==2) && ignore_lhcp,  continue;  end
      switch i
      case 1
          tempa  = (data{j}.profile.original + data{j}.profile.offset);
          tempaa = (data{j}.sphharm.original_fit + data{j}.sphharm.offset);
          tit = sprintf('Offset gain (dB)\n%s', data{j}.filename(1:end-9));
          filename = [data{j}.filename(1:end-9) '-decibel-offset.png'];
      case 2
          tempa = (data{j}.profile.original);
          tempaa = (data{j}.sphharm.original_fit);
          tit = sprintf('Gain (dB)\n%s', data{j}.filename(1:end-9));
          filename = [data{j}.filename(1:end-9) '-decibel.png'];
      case 3
          tempa = (data{j}.profile.power_gain_lin);
          tempaa = (data{j}.sphharm.amplitude_gain_lin_fit.^2);
          tit = sprintf('Power gain (linear)\n%s', data{j}.filename(1:end-9));
          filename = [data{j}.filename(1:end-9) '-power.png'];
      case 4
          tempa = (data{j}.profile.amplitude_gain_lin);
          tempaa = (data{j}.sphharm.amplitude_gain_lin_fit);
          tit = sprintf('Amplitude gain (linear)\n%s', data{j}.filename(1:end-9));
          filename = [data{j}.filename(1:end-9) '-amplitude.png'];
      end
      switch j
      case 1  % RHCP
          color = 'b';
          tempb = max(-tempa);
          tempb = ceil(tempb/10)*10;
          if ~isempty(maxval),  tempb = maxval;  end
          temp = tempa + tempb;
          temp1 = max(temp);
          temp2 = min(temp);
          temp1 =  ceil(temp1/10)*10;
          temp2 = floor(temp2/10)*10;
          temp2 = max(temp2, 0);
          if ~isempty(maxval),  temp1 = maxval;  end
          temp5 = 10;
          if (((temp1 - temp2) / temp5) < 3),  temp5 = 5;  end
          temp3 = (temp1:-temp5:temp2) - tempb;
          temp4 = arrayfun(@(x) sprintf('%d', x), temp3, ...
              'UniformOutput',false);
      case 2  % LHCP
          color = 'r';
          temp = tempa + tempb;
      end
  %temp4 = [];
  %figure, plot(data{j}.profile.ang*pi/180, temp, '-k')
  pp2 = @(ang, val, lc) pp(ang, val, ...  % raw values
      'RingStep',temp5, ...
      'RingTickLabel',temp4, ...
      'ThetaDirection','cw', ...
      'ThetaStartAngle',+270, ...
      'MaxValue',temp1, ...
      'CentreValue',temp2, ...
      ...%'Marker','.', ...
      'Marker','none', ...
      'LineStyle','-', ...
      'LineColor',lc, ...
      'LineWidth',2 ...
  );

  pp2(data{j}.profile.ang*pi/180, temp, 'k')  % raw values
  hold on
  pp2(data{j}.sphharm.ang*pi/180, tempaa + tempb, color)  % fitted values
  hold on
  axis equal
  title(tit, 'Interpreter','none')
  end
  if ~isempty(dir)  
    saveas(gcf, fullfile(dir, filename))
    close(gcf)
  end
end

end

