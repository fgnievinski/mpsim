function [data_all, elev_all] = plotpovse (answers, f, lab, fz, in_color, vs_sine, field, field2, lab2, tick2)
  if (nargin < 4) || isempty(fz),  fz = 0:1:10;  end
  if (nargin < 5) || isempty(in_color),  in_color = true;  end
  if (nargin < 6) || isempty(vs_sine),  vs_sine = true;  end
  if (nargin < 7) || isempty(field),  field = 'cphasor';  end
  if (nargin < 8) || isempty(field2),  field2 = 'fresnel_zone';  end
  if (nargin < 9) || isempty(lab2),  lab2 = 'FZ';  end
  if (nargin <10) || isempty(tick2),  tick2 = fz(:);  end
  method = 'linear';
  %method = 'cubic';
  %method = 'spline';
  %method = 'nearest';

  %speedup = false;  % DEBUG
  speedup = true;  % DEBUG
  %disp(speedup)  % DEBUG
  fz_tol = 1;

  if (nargin(f) > 1),  f = @(answer) f(answer, field);  end
  
  data_all = NaN(numel(answers), numel(fz));
  elev_all = NaN(numel(answers), 1);
  for i=1:numel(answers)
    if speedup
      idx = (answers(i).map.(field2) < (fz(1)   - fz_tol)) ...
          | (answers(i).map.(field2) > (fz(end) + fz_tol));
      idx = idx | isnan(answers(i).map.(field));    
      answers(i).map.(field2)(idx) = [];
      answers(i).map.(field)(idx) = [];
    end
    temp0 = f(answers(i));
    [temp1, temp2] = unique(answers(i).map.(field2)(:));  temp0b = temp0(temp2);
    %[temp1, temp0b] = uniquem(answers(i).map.(field2)(:), temp0(:));
    %fz_tol2 = 0.1;  fz2 = bsxfun(@plus, fz(:)', fz_tol2*[-1 0 +1]');
    %data = interp1(temp1, temp0b, fz2, method, 'extrap');
    %data = mean(data, 1);
    data = interp1(temp1, temp0b, fz(:)', method);
    data_all(i,:) = data;
    elev_all(i) = answers(i).info.elev;
  end

%   sinelev = sind(elev);
%   if differentiateit,  for j=numel(fz):-1:1 %#ok<ALIGN>
%     data(:,j) = gradient(sinelev, data(:,j));
%   end,  end

  if vs_sine,  indep = sind(elev_all);  else  indep = elev_all;  end
  figure
  hold on
  %for j=1:numel(fz)
  for j=numel(fz):-1:1
    if in_color
      h(j) = cline(indep, data_all(:,j), repmat(fz(j), size(elev_all)));
        set(h(j), 'LineWidth',2)
    else
      c = [1 1 1]*(0.9-0.6*j/numel(fz));
      h(j) = plot(indep, data_all(:,j), '-', 'Color',c, 'LineWidth',3);
    end
  end
  %hline(0, 'k')
  grid on
  xlabel('Elevation angle (degrees)')
  ylabel(lab)
  %xlim(indep([1,end]))
  xlim([min(indep), max(indep)])
  
  if in_color
    h = colorbar;
      title(h, lab2)
      if ~isnan(tick2),  set(h, 'YTick',tick2);  end
  else
    temp = num2str(reshape(fz,[],1), '%.1f');
    h=legend(h, temp, 'Location','NorthEast');
    legendtitle(h, lab2)
  end
  
  doit = @(axis) set(axis, 'XTickLabel',num2str(asind(get(axis, 'XTick'))', '%.1f'));
  if vs_sine
    %set(gca, 'XTick',sind(sort(elev_all(:))))
    doit(gca);
    set(gcf, 'ResizeFcn',@(src,evt) doit(get(src, 'CurrentAxes')), 'PaperPositionMode','auto');
  end
  
  maximize()
  fixfig()
  if (nargout < 2),  clear elev_all;  end
  if (nargout < 1),  clear data_all;  end
end
