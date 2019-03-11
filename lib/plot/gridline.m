function h = gridline (x, y, u, v, s, ls, varargin)
    % rows and columns form lines that we'll distort with u and v.
    x = x + u*s;
    y = y + v*s;

    % add NaNs as line breaks for plot:
    f = @(z) [NaN(1,size(z,2)+1); [NaN(size(z,1),1) z]];
    x = f(x);
    y = f(y);
    u = f(u);
    v = f(v);
    
    hold on
    %if p(1)
       h(1) = plot (reshape(x,  [], 1), reshape(y,  [], 1), ls, varargin{:});
    %end
    %if p(2)
       h(2) = plot (reshape(x', [], 1), reshape(y', [], 1), ls, varargin{:});
    %end

    if (nargout < 1),  clear h;  end
end

