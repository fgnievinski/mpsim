function filename = unzip_if_needed (filename, outputdir)
    if (nargin < 2),  outputdir = [];  end

    idx = strendi('.zip', filename);
    if any(idx),  filename(idx) = unzip(filename(idx), outputdir);  end

    idx = strendi('.gz', filename);
    if any(idx),  filename(idx) = gunzip(filename(idx), outputdir);  end

    idx = strendi('.z', filename);
    if any(idx),  filename(idx) = zunzip(filename(idx), outputdir);  end
end

