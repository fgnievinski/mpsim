function nrml_dir = position2normal_2d (pos)
  nrml_dir = tangent2normal_2d(normalize_all(gradient_all(pos)));
end
