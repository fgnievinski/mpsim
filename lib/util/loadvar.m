function out = loadvar (filename)
    out = getfield1(load(filename));
end
