function prof_h_geopot = convert_to_geopot_height3 (pos_geod, prof_h_geom, opt)
    temp = NaN(numel(prof_h_geom),3);
    temp(:,1) = pos_geod(1);
    temp(:,2) = pos_geod(2);
    temp(:,3) = prof_h_geom(:);
    prof_h_geopot = convert_to_geopot_height2 (temp, opt.vert_pos_method, opt);
end

