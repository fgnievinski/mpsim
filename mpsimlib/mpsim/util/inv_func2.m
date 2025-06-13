function [x, y2] = inv_func2 (f, y, x0, tolx, toly, ...
display, individually, provide_jacob)
    if (nargin < 4),  tolx = [];  end
    if (nargin < 5),  toly = [];  end
    if (nargin < 6) || isempty(display),  display = 'off';  end
    if (nargin < 7) || isempty(individually),  individually = false;  end
    if (nargin < 8),  provide_jacob = [];  end
    %provide_jacob = false;  % DEBUG
    
    if individually
        if ~isempty(provide_jacob) && provide_jacob
            warning('MATLAB:inv_func2:notSupp', 'Option not supported.');
        end
        assert(isvector(y))
        assert(isvector(x0))
        siz = size(x0);
        n = prod(siz);
        assert(numel(y) == n);
        x = zeros(siz);
        y2 = zeros(siz);
        for i=1:n
            [x(i), y2(i)] = inv_func (@(h) f(h,i), y(i), x0(i), ...
                tolx, toly, display);
        end
    else
        F = @(x) f(x) - y;
        opt2 = optimset('TolX',tolx, 'TolFun',toly, 'Display',display, ...
            ...%'Algorithm','trust-region-reflective',...
            'Algorithm','levenberg-marquardt', 'ScaleProblem','Jacobian', ...
            'JacobPattern',speye(numel(x0)), ...
            ...%'PrecondBandWidth',0);  % slower)
            'PrecondBandWidth',Inf);
        G = F;
        if isempty(provide_jacob) || provide_jacob
            %h = tolx;
            h = sqrt(tolx);
            G = @(x) diff_func_fwd(F, x, h);
            opt2 = optimset(opt2, 'Jacobian','on');
        end
        [x, temp] = fsolve(G, x0, opt2);
        y2 = y + temp;
    end
end
