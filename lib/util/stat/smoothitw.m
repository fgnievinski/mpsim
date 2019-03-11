function [iavg, itime, iweight_sum] = smoothitw (...
time, obs, weight, dt, itime, ...
ignore_self, robustify)
%SMOOTHITW  Weighted running average.
    if (nargin < 5),  itime = [];  end
    if (nargin < 6),  ignore_self = false;  end
    if (nargin < 7),  robustify = false;  end
    
    dim = 1;
    ignore_nans = [];
    h = @(obs, weight) nanavgwr (obs, weight, dim, ignore_nans, robustify);
    g = @(in) deal_out2vec(@() h(in(:,1), in(:,2)), 2);
    f = g;
    in = [obs weight];
    [out, itime] = smoothit(time, in, dt, itime, f, [], [], ignore_self);
    [iavg, iweight_sum] = deal2(out, 1);
end
