function [lim, conf] = get_conf_lim (avg, se, dof, conf, tail, ...
output_obs_or_mean, input_obs_or_mean, multiple_correction_type, num_comparisons)
%GET_CONF_LIM  Confidence interval, for the observation mean.
% 
%  See also GET_PRED_LIM.

    if (nargin < 4),  conf = [];  end
    if (nargin < 5),  tail = [];  end
    if (nargin < 6),   output_obs_or_mean = [];  end
    if (nargin < 7),    input_obs_or_mean = [];  end
    if (nargin < 8),  multiple_correction_type = [];  end
    if (nargin < 9),  num_comparisons = [];  end
    
    if isempty(output_obs_or_mean),  output_obs_or_mean = 'mean';  end

    [lim, conf] = get_confpred_lim (avg, se, dof, conf, tail, ...
      output_obs_or_mean, input_obs_or_mean, multiple_correction_type, num_comparisons);
end
