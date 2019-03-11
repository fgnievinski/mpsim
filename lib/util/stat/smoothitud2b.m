function [istd_scale, itime] = smoothitud2b (...
num_params, ...
time, resid, std, dof, dt, itime, ...
ignore_self, robustify)
%SMOOTHITUD2B  Second-order uncertainty-weighted running average, with varying degree of freedom (alternative formulation).

    if (nargin < 7),  itime = [];  end
    if (nargin < 8),  ignore_self = false;  end
    if (nargin < 9),  robustify = false;  end
    dim = 1;
    ignore_nans = [];
    input_x = false;
    f = @(in) nanrmssur2 (num_params, in(:,1), in(:,2), dim, ignore_nans, robustify);
    in = [resid std];
    [istd_scale, itime] = smoothit(time, in, dt, itime, f, ignore_nans, input_x, ignore_self);
end
