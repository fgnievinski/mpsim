function prof_h_geom = convert_from_geopot_height3 (pos_geod, prof_h_geopot, opt)
    temp = NaN(numel(prof_h_geopot),3);
    temp(:,1) = pos_geod(1);
    temp(:,2) = pos_geod(2);
    temp(:,3) = prof_h_geopot(:);
    prof_h_geom = convert_from_geopot_height2 (temp, opt.vert_pos_method, opt);
end

