function [c, n] = polyd2c (d)
    n = d + 1;
    if isnan(d),  c = [];  else  c = zeros(1, n);  end
    %if isnan(d),  c = [];  else  c = zeros(n, 1);  end  % WRONG! breaks polydesign1a
end

