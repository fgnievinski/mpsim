function c = bwr (m)
    if (nargin < 1) || isempty(m),  m = size(get(gcf,'colormap'),1);  end  % like in jet.m
        
    % # of whites:
    if (mod(m, 2) == 1)
        % if m is odd, there is one single central white row.
        nw = 1;
    else
        % if m is even, there will be two central white rows.
        nw = 2;
    end

    % # of reds and blues:
    n = (m - nw) / 2;

    % DEBUG:
    %m
    %nw
    %n

    blues  = [((0:n-1)./n)', ((0:n-1)./n)', ones(n, 1)];
    whites = repmat([1 1 1], nw, 1);
    reds   = [ones(n, 1), ((n-1:-1:0)./n)', ((n-1:-1:0)./n)'];
    
    c = [blues; whites; reds];
end

