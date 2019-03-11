function Y = strprctile (X, pstr)
    p = str2double(pstr);
    if (p > 50),  p = 100 - p;  end
    p = [p/2, 100-p/2];
    Y = prctile (X, p);    
end
