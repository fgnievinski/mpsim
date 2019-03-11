function plot_myprofile (thetitle, p_full, p_sparse, p_packed)
    figure
    hold on
    plot(p_full.order,   p_full.memsize./1e6, '.-k')
    plot(p_sparse.order, p_sparse.memsize./1e6, '+-b')
    plot(p_packed.order, p_packed.memsize./1e6, 'X-r')
    xlabel('Order')
    ylabel('Memory size (Mbytes)')
    legend('Full', 'Sparse', 'Packed')
    title(thetitle)
    grid on

    figure
    hold on
    plot(p_full.order,   p_full.time./60, '.-k')
    plot(p_sparse.order, p_sparse.time./60, '+-b')
    plot(p_packed.order, p_packed.time./60, 'X-r')
    xlabel('Order')
    ylabel('Processing Time (min)')
    legend('Full', 'Sparse', 'Packed')
    title(thetitle)
    grid on


%    figure
%    hold on
%    plot(p_full.order.^2,   p_full.memsize./1e6, '.-k')
%    plot(p_sparse.order.^2, p_sparse.memsize./1e6, '+-b')
%    plot(p_packed.order.^2, p_packed.memsize./1e6, 'X-r')
%    xlabel('# elements')
%    ylabel('Memory size (Mbytes)')
%    legend('Full', 'Sparse', 'Packed')
%    title(thetitle)
%    grid on
%
%    figure
%    hold on
%    plot(p_full.order.^2,   p_full.time./60, '.-k')
%    plot(p_sparse.order.^2, p_sparse.time./60, '+-b')
%    plot(p_packed.order.^2, p_packed.time./60, 'X-r')
%    xlabel('# elements')
%    ylabel('Processing Time (min)')
%    legend('Full', 'Sparse', 'Packed')
%    title(thetitle)
%    grid on

end

