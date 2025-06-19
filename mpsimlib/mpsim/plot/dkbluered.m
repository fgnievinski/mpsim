function out = dkbluered (n)
    if (nargin < 1) || isempty(n),  n = size(get(gcf,'colormap'),1);  end  % like in jet.m
    out = colormap(cptcmap('dkbluered', 'ncol',n));
end

