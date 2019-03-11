function conf2 = get_outlier_conf2 (num_tests, conf, type)
    if (nargin < 2),  conf = [];  end
    if (nargin < 3),  type = [];  end
    conf2 = 1-get_outlier_alpha2 (num_tests, 1-conf, type);
end
