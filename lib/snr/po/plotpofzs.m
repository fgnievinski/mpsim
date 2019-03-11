function plotpofzs (answer, img, fz_max, open_fig, in_color, num_pts_max)
    if (nargin < 3) || isempty(fz_max)
        if isfield(answer.info, 'x_lim0') ...
        && isfield(answer.info, 'y_lim0')
            fz_max = interp2(answer.map.x, answer.map.y, answer.map.fresnel_zone, 0, answer.info.y_lim0(2));
        else
            fz_max = answer.info.fz_border;
            %fz_max = max(max(answer.map.fresnel_zone(~isnan(answer.map.fresnel_zone))));
        end
    end
    if (nargin < 4) || isempty(open_fig),  open_fig = true;  end
    if (nargin < 5) || isempty(in_color),  in_color = true;  end
    if (nargin < 6) || isempty(num_pts_max),  num_pts_max = 1000;  end
    %in_color = false;  % DEBUG
    
    %ind = answer.map.ind_delay(answer.map.fresnel_zone < fz_max);  % WRONG!
    ind = answer.map.ind_delay(answer.map.fresnel_zone(answer.map.ind_delay) < fz_max);
      %answer.map.fresnel_zone(ind(1:10))  % DEBUG
      assert(answer.map.fresnel_zone(ind(1)) == 0)
    ind = ind(round(linspace(1, numel(ind), num_pts_max)));
    
    if open_fig,  figure();  end
    if in_color
        h = cline(answer.map.fresnel_zone(ind), img(ind), answer.map.fresnel_zone(ind));
          set(h, 'LineWidth',2)
    else
        plot(answer.map.fresnel_zone(ind), img(ind), '-', 'LineWidth',2)
    end
    grid on
    xlabel('Fresnel zone')
    %xlim([-1/3*diff(xlim())/50 getel(xlim(),2)])
end
