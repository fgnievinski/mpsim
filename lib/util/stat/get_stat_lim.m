function [ml, sl] = get_stat_lim (c, mean, std, n, nullify_zeros, type)
% see also: get_pred_lim, get_conf_lim
    if isempty(c),  c = 0.99;  end
    if isempty(mean),  mean = zeros(size(std));  end
    if isempty(std),  std = ones(size(mean));  end
    if isempty(mean) && isempty(std),  mean = 0;  std = 1;  end
    myassert(size(mean), size(std))
    if (nargin < 5) || isempty(nullify_zeros),  nullify_zeros = true;  end
    if (nargin < 6) || isempty(type),  type = 'absolute';  end
    if nullify_zeros,  std(std==0) = NaN;  end
    var = std.^2;
    %ind = find(size(mean)==1);  % singleton dim.
    
    if any(c < 0.5) ...  % it seems a significance level was input instead
    || any(c > 1.0)      % it seems a percentage was input instead
        warning('MATLAB:get_conf_int:badConf', ...
            ['Confidence level (first argument) seems erroneous -- '...
             'usually it''s 95%% or 99%%.'])
    end

    s = (1-c)/2;  % two-tailed significance level
    ll = s;  % lower limit
    lu = 1-s;  % upper limit

    p = 1;  % or 2? (actually, it should be the regression num of param)
    dof = n - p;
         
    fu = tinv(ll, dof);  % upper factor
    fl = tinv(lu, dof);  % lower factor
    dmeanl = sqrt(var./n).*fl;
    dmeanu = sqrt(var./n).*fu;
    switch type
    case 'absolute'
        meanl = mean + dmeanl;
        meanu = mean + dmeanu;
        ml = {meanl, meanu};
    case 'relative'
        ml = {dmeanl, dmeanu};
    case {'single','max'}
        ml = max(abs(dmeanl), abs(dmeanu));
    end

    if (nargout < 2),  return;  end
    
    fu = dof./chi2inv(ll, dof);  % upper factor
    fl = dof./chi2inv(lu, dof);  % lower factor
    varl = var.*fl;
    varu = var.*fu;
    stdl = sqrt(varl);
    stdu = sqrt(varu);
    if strcmp(type, 'absolute'),  sl = {stdl, stdu};  return;  end
    dstdl = stdl - std;
    dstdu = stdu - std;
    switch type
    case 'relative'
        sl = {dstdl, dstdu};
    case {'single','max'}
        sl = max(abs(dstdl), abs(dstdu));
    end
end

