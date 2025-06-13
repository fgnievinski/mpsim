function [z, r, fz] = plotporcs (answer, img, radial_lim, num_pts, method, open_fig, fz_cutoff, base)
    if (nargin < 3) || isempty(radial_lim)
        if isfield(answer.info, 'x_lim0') ...
        && isfield(answer.info, 'y_lim0')
        	radial_lim = sqrt(diff(answer.info.x_lim0)^2 + diff(answer.info.y_lim0));
        else
        	radial_lim = sqrt(diff(answer.info.x_lim)^2 + diff(answer.info.y_lim));
            %radial_max = 75;
        end
    end
    if (nargin < 4) || isempty(num_pts),  num_pts = 1000;  end
    if (nargin < 5) || isempty(method),  method = '*cubic';  end  % important in touching 100%.
    if (nargin < 6) || isempty(open_fig),  open_fig = true;  end
    if (nargin < 7) || isempty(fz_cutoff),  fz_cutoff = [0 1/2 1 2];  end
    if isnan(fz_cutoff),  fz_cutoff = [];  end
    if (nargin < 8) || isempty(base),  base = 0;  end
    if all(isfield(answer.info, {'x_domain2','y_domain2'}))
        [answer.map.x, answer.map.y] = meshgrid(answer.info.x_domain2, answer.info.y_domain2);
    else
        [answer.map.x, answer.map.y] = meshgrid(answer.info.x_domain, answer.info.y_domain);
    end
    temp = struct('x',answer.map.x, 'y',answer.map.y, 'z',img);
    azim = 0;
    [z, r] = dem_cross_section (temp, azim, radial_lim, num_pts, method);
    for i=1:numel(fz_cutoff)
        if ~isfield(answer.map, 'fresnel_zone')
            warning('snr:plotporcs:noFZ', 'No answer.map.frensel_zone; ignoring fz_cutoff.');
            break;
        end
        if (fz_cutoff(i) == 0)  % sp. pt.
            temp = get_fresnel_zone(answer.info.height_ant, ...
               answer.info.elev, answer.info.azim, answer.info.wavelength, fz_cutoff(i));
            fz(i) = getfields(temp, {'a','R'});
            continue;
        end
        idx = (answer.map.fresnel_zone <= fz_cutoff(i));
        fz(i) = struct('a',range(answer.map.y(idx))/2, 'R',median(answer.map.y(idx)));
    end
    if isnan(open_fig),  return;  end
    if open_fig,  figure();  end
    plot(r, z, '-k', 'LineWidth',2), grid on%, ylim([-0.2,+1])
    vline(0, {'--k', 'LineWidth',2})
    xlabel('Radial distance (m)')
    %xlim(radial_lim)  % WRONG! might be 1- or 2-elem vec.
    xlim(r([1,end]))
    hold on
    yl = ylim();
    try
    for i=1:numel(fz_cutoff)
        if (fz_cutoff(i) == 0)  % sp. pt.
            %temp = yl;
            %temp = [base interp1(r, z, fz(i).R)];
            %plot(fz(i).R * [1 1], temp, ':k', 'LineWidth',2);
            vline(fz(i).R, {'LineStyle','-.', 'Color','k', 'LineWidth',2});
            continue;
        end
        %h(i) = area(fz(i).R + fz(i).a .* [-1,+1], repmat(yl(2), [1 2]), yl(1));
        idx = ( (fz(i).R - fz(i).a) <= r & r <= (fz(i).R + fz(i).a) );
        h(i) = area(r(idx), z(idx), base);%yl(1));
        uistack(h(i), 'bottom')
        set(h(i), 'EdgeColor','none', 'FaceColor',0.35+0.5*[1 1 1]*(i/numel(fz_cutoff)))
    end
    catch
    end
    set(gca(), 'Layer','top');
    %ylim(yl)
    if (nargout == 0),  clear r z;  end
    maximize()
end
