function pos = get_specular_circles (height, elev_domain, ...
slope, aspect, num_pts)
    assert(isscalar(height))
    if (nargin < 3),  slope = [];  end
    if (nargin < 4),  aspect = [];  end
    if (nargin < 5) || isempty(num_pts),  num_pts = 100;  end
    num_circles = length(elev_domain);
    azim_domain = linspace(0,360, num_pts)';
    pos = arrayfun(@(i) get_specular_point (...
        height, repmat(elev_domain(i), num_pts,1), azim_domain, ...
        slope, aspect), ...
        (1:num_circles)', 'UniformOutput',false);
end

%!test
%! temp = [...
%!      8   202
%!     15   203
%!     22   205
%!     29   207
%!     37   210
%!     45   213
%!     52   217
%!     60   223
%!     68   232
%!     75   245
%!     80   -86
%!     82   -32
%!     77     6
%!     71    24
%!     65    35
%!     58    43
%!     52    50
%!     46    57
%!     40    63
%!     34    69
%!     29    74
%!     24    80
%!     18    86
%!     13    91
%!      8    96
%! ];
%! elev = temp(:,1);
%! azim = temp(:,2);
%! height = 2;
%! slope = 2;
%! aspect = 120;
%! refl_pos = get_specular_reflection (height, elev, azim, slope, aspect);
%! circ_elev = [1, 2, 3, 4, 5, 10, 15, 30];
%! circ_pos = get_specular_circles (height, circ_elev, slope, aspect);
%! figure
%!   plot(refl_pos(:,2), refl_pos(:,1), '.-k')
%!   axis equal 
%!   lim = [-1,+1]*ceil(max(abs([xlim(),ylim()])));
%!   xlim(lim)
%!   ylim(lim)
%!   grid on
%!   hold on
%!   arrayfun(@(i) plot(...
%!     circ_pos{i}(:,2), circ_pos{i}(:,1), ...
%!     '-', 'Color',[1 1 1]*0.5), ...
%!     1:length(circ_elev));
%!   arrayfun(@(i) text(...
%!     circ_pos{i}(1,2), circ_pos{i}(1,1), ...
%!     num2str(circ_elev(i), '%d^\\circ'), ...
%!     'Visible','on', ...
%!     'HorizontalAlignment','center', 'FontSize',14, ...
%!     'FontWeight','bold', 'Color',[1 1 1]*0.4, 'BackgroundColor','white'), ...
%!     1:length(circ_elev));

