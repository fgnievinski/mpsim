function [pos_specular, idx_keep, idx_affz, ind_keep, ind_affz, delay_excess] ...
= snr_po_spm (delay, x_domain, y_domain, wavelength, num_specular_max, fresnel_zone_keep, ...
delay_grad_norm_min, fresnel_zone_affz, single, plotit)
    if (nargin < 5) || isempty(num_specular_max),  num_specular_max = 3;  end
    if (nargin < 6) || isempty(fresnel_zone_keep),  fresnel_zone_keep = 1;  end
    if (nargin < 7) || isempty(delay_grad_norm_min),  delay_grad_norm_min = 1/100;  end
    if (nargin < 8) || isempty(fresnel_zone_affz),  fresnel_zone_affz = (1/2);  end
    if (nargin < 9) || isempty(single),  single = true;  end
    if (nargin <10) || isempty(plotit),  plotit = false;  end    
    %plotit = true;  % DEBUG
    %single = false;  % DEBUG
    %fresnel_zone_keep = fresnel_zone_keep + 0.01;  % DEBUG
    
    if single,  delay = cast(delay, 'single');  end
    
    % criterion for keeping pixels in the integration:
    delay_excess_keep = fresnel2delay(fresnel_zone_keep, wavelength);
    % criterion for separating a specular point's Fresnel zone from another point's:
    delay_excess_affz = fresnel2delay(fresnel_zone_affz, wavelength);
    % Note: usually delay_excess_keep >> fresnel_zone_affz because 
    % the integration does not converge fast.
    
    siz = size(delay);
    ind_keep = zeros(siz);  % index to which FZ a pixel belongs to.
    ind_affz = zeros(siz);  % index to which FZ a pixel belongs to.
    pos_specular = struct('x',[], 'y',[]);  % list of specular points.
    if (num_specular_max < 1)
        delay_excess = NaN(siz);
        idx_keep = true(siz);
        idx_affz = true(siz);
        return;
    end
    
    [delay_specular, ind_specular] = min(delay(:));
    delay_excess = delay - delay_specular;
    idx_keep = (delay_excess < delay_excess_keep);
    idx_affz = (delay_excess < delay_excess_affz);
    ind_keep(idx_keep) = 1;  % pixels that belong to the first specular pt.
    ind_affz(idx_affz) = 1;  % pixels that belong to the first specular pt.
      pos_specular = collect_pos_specular (pos_specular, ind_specular);
      plot_fnc('delay_excess./wavelength', 'excess delay (w.r.t. main specular pt) (\lambda)');
      plot_fnc('log10(delay_excess./wavelength)', 'excess delay (w.r.t. main specular pt) (\lambda, log)');
        %hold on, plot(pos_specular.x, pos_specular.y, '+w', 'MarkerSize',25, 'LineWidth',3)
      plot_fnc('idx_keep', 'pixels to keep');
      plot_fnc('ind_affz', 'pixels in approx. FZ');

    if (num_specular_max < 2),  return;  end

    [dgradx_map, dgrady_map] = gradient(delay, x_domain, y_domain);
    delay_grad_norm = hypot(dgradx_map, dgrady_map);
      clear dgradx_map dgrady_map
    delay_grad_norm2 = delay_grad_norm;  % (it'll be modified)
      if ~plotit,  delay_grad_norm = [];  end  %#ok<NASGU> %  clear delay_grad_norm
      plot_fnc('delay_grad_norm', 'delay horiz grad norm (m/m)');
      plot_fnc('log10(delay_grad_norm)', 'delay horiz grad norm (m/m), log');

    for i=2:num_specular_max
        %close all  % DEBUG
        % mask out pixels within a previous specular pt's approx. Fresnel zone:
        delay_grad_norm2(idx_affz) = Inf;
        %delay_grad_norm2(idx_keep) = Inf;  % WRONG! this would mask out new sp. points.
        [delay_grad_norm_specular, ind_specular] = min(delay_grad_norm2(:));
          plot_fnc('log10(delay_grad_norm)', 'delay horiz grad norm (m/m), log');
          %pos_specular2 = collect_pos_specular (pos_specular, ind_specular);
          %hold on, plot(pos_specular2.x, pos_specular2.y, '+w', 'MarkerSize',25, 'LineWidth',3)
        if (delay_grad_norm_specular > delay_grad_norm_min),  break;  end
        pos_specular = collect_pos_specular (pos_specular, ind_specular);
        delay_specular = delay(ind_specular);
        delay_excess2 = delay - delay_specular;
        delay_excess2 = abs(delay_excess2);
          plot_fnc('delay_excess2./wavelength', 'excess delay (w.r.t. current specular pt) (m)');
            %set(gca, 'CLim',[min(delay_excess2(:))/wavelength,delay_excess_keep_in_wavelengths]);
          %plot_fnc('delay_excess2./wavelength', 'excess delay (w.r.t. current specular pt) (m)'), colormap(dkbluered), colorlim(delay_excess2, 1, gca(), [], [min(delay_excess2(:))/wavelength,delay_excess_keep_in_wavelengths]);
        % deal with pixels closer to a previous specular pt:
        delay_excess = min(delay_excess, delay_excess2);  % element-wise.
          plot_fnc('delay_excess2./wavelength', 'excess delay (w.r.t. current specular pt) (\lambda)');
            %set(gca, 'CLim',[0,delay_excess_keep_in_wavelengths]);
          plot_fnc('log10(delay_excess2./wavelength)', 'excess delay (w.r.t. current specular pt) (\lambda, log)');
        idx_keep = (delay_excess < delay_excess_keep);
        idx_affz = (delay_excess < delay_excess_affz);
        idx_keep2 = (delay_excess2 < delay_excess_keep);
        idx_affz2 = (delay_excess2 < delay_excess_affz);
        ind_keep(idx_keep2) = i;
        ind_affz(idx_affz2) = i;
        %ind_affz(idx_affz) = i;  % WRONG!
        %ind_affz = ind_affz + double(idx_affz2);  % WRONG!
          plot_fnc('delay_excess./wavelength', 'excess delay (w.r.t. any specular pt) (m)');
            %set(gca, 'CLim',[0,delay_excess_keep_in_wavelengths]);
          plot_fnc('log10(delay_excess./wavelength)', 'excess delay (w.r.t. any specular pt) (\lambda, log)');
          plot_fnc('idx_keep', 'pixels to keep');
          plot_fnc('ind_affz', 'pixels in approx. FZ');
            %hold on, plot(pos_specular.x, pos_specular.y, '+w', 'MarkerSize',25, 'LineWidth',3)
    end
    
    function pos_specular = collect_pos_specular (pos_specular, ind_specular)
        [I,J] = ind2sub(siz, ind_specular);
        pos_specular.x(end+1,1) = x_domain(J);
        pos_specular.y(end+1,1) = y_domain(I);
    end

    function plot_fnc (str_in, tit)
        if ~plotit,  return;  end
        in = eval(str_in);
        temp = struct('map',struct('x_domain',x_domain, 'y_domain',y_domain));
        plotpo(temp, @(map) in, 'jet', [], [], tit, false);
    end
end

