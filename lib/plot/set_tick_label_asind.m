function set_tick_label_asind (XY, format)
    if (nargin < 1) || isempty(XY),  XY = 'X';  end
    if (nargin < 2) || isempty(format),  format = '%.1f';  end
    if ~ischar(format),  prec = format;  format = sprintf('%%.%df', prec);  end
    %format  % DEBUG
    XYTick = [XY 'Tick'];
    XYTickLabel = [XYTick 'Label'];
    temp = num2str(asind(get(gca, XYTick))', format);
    set(gca, XYTickLabel,temp);
    set(gcf, 'ResizeFcn',{@(src, eventdata) set_tick_label_asind(XY, format)});
end

