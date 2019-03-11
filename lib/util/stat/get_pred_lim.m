function [lim, conf] = get_pred_lim (avg, se, dof, conf, tail, ...
output_obs_or_mean, input_obs_or_mean, multiple_correction_type, num_comparisons)
%GET_PRED_LIM  Prediction interval, for a new observation.
% 
%  See also GET_CONF_LIM.

    if (nargin < 4),  conf = [];  end
    if (nargin < 5),  tail = [];  end
    if (nargin < 6),   output_obs_or_mean = [];  end
    if (nargin < 7),    input_obs_or_mean = [];  end
    if (nargin < 8),  multiple_correction_type = [];  end
    if (nargin < 9),  num_comparisons = [];  end
    
    if isempty(output_obs_or_mean),  output_obs_or_mean = 'obs';  end

    [lim, conf] = get_confpred_lim (avg, se, dof, conf, tail, ...
      output_obs_or_mean, input_obs_or_mean, multiple_correction_type, num_comparisons);
end
