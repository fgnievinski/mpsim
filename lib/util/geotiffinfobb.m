function bb = geotiffinfobb (info)
    bb.XMin = min(info.CornerCoords.X);
    bb.XMax = max(info.CornerCoords.X);
    bb.YMin = min(info.CornerCoords.Y);
    bb.YMax = max(info.CornerCoords.Y);
    bb.XLim = [bb.XMin, bb.XMax];
    bb.YLim = [bb.YMin, bb.YMax];
end

