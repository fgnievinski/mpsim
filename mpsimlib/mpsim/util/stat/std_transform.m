function varargout = std_transform (trans, mean, std, lim, lim2, rate_trans, method)
    if (nargin < 4),  lim = [];  end
    if (nargin < 5),  lim2 = [];  end
    if (nargin < 6),  rate_trans = [];  end
    if (nargin < 7) || isempty(method)
        if (nargin < 6),  method = 1;  else  method = 2;  end
    end
    [std2l, std2u, std2] = feval(['std_transform_aux' num2str(method)], ...
        trans, mean, std, lim, lim2, rate_trans);
    if (nargout < 2)
        varargout = {std2};
    else
        varargout = {std2l, std2u};
    end
    if any(cellfun(@(v) ~all((isfinite(v) & isreal(v)) | isnan(v)), varargout))
        warning('matlab:std_transform:complex', ...
            ['Complex-valued or infinite results detected;\n'...
             'please check transformation function and original/transformed limits.']);
    end
end
%#ok<*DEFNU>

%%
function [std2l, std2u, std2] = std_transform_aux2 (trans, mean, std, lim, lim2, rate_trans)
    if ~isempty(lim) || ~isempty(lim2)
        error('matlab:std_transform:badArg', ...
            ['Limits not supported with this method; ' ...
             'please chose another method.']);
    end
    if isempty(rate_trans),  rate_trans = @(x) diff_func(trans, x);  end
    rate = rate_trans(mean);
    std2 = std .* abs(rate);
    %var2 = std.^2 .* rate.^2;
    std2l = std2;
    std2u = std2;
end

%%
function [std2l, std2u, std2] = std_transform_aux1 (trans, mean, std, lim, lim2, rate_trans)
    if ~isempty(rate_trans)
        error('matlab:std_transform:badArg', ...
            ['Rate-transformation not supported with this method; ' ...
             'please chose another method.']);
    end
    [std_lower, std_upper] = std2lu (std, mean);
    lower = mean - std_lower;
    upper = mean + std_upper;
    [lower, upper, mean] = check_lim (lower, upper, mean, lim);
    lower2 = trans(lower);
    upper2 = trans(upper);
    mean2  = trans(mean);
    [lower2, upper2, mean2] = check_lim (lower2, upper2, mean2, lim2);
    std2u = upper2 - mean2;
    std2l =          mean2 - lower2;
    std2 = max(abs(std2l), abs(std2u));
end

%%
function [lower2, upper2, mean2] = check_lim (lower2, upper2, mean2, lim2)
    if isempty(lim2),  lim2 = Inf;  end
    if isscalar(lim2), lim2 = [-1,+1].*lim2;  end
    if isequal(lim2, [-Inf +Inf]),  return;  end
    lower2(lower2 < lim2(1)) = lim2(1);  % = max(lower2, lim2(1));
    upper2(upper2 > lim2(2)) = lim2(2);  % = min(lower2, lim2(2));
     mean2( mean2 < lim2(1)) = lim2(1);  % = max( mean2, lim2(1));
     mean2( mean2 > lim2(2)) = lim2(2);  % = min( mean2, lim2(2));
end
