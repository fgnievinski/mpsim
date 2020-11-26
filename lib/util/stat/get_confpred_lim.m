function [lim, conf] = get_confpred_lim (avg, se, dof, conf, tail, ...
output_obs_or_mean, input_obs_or_mean, multiple_correction_type, num_comparisons)
%GET_CONFPRED_LIM  Confidence or prediction interval, for a new observation or for the mean.
% 
%  See also GET_VAR_LIM.

    if (nargin < 4),  conf = [];  end
    if (nargin < 5),  tail = [];  end
    if (nargin < 6),   output_obs_or_mean = [];  end
    if (nargin < 7),    input_obs_or_mean = [];  end
    if (nargin < 8),  multiple_correction_type = [];  end
    if (nargin < 9) || isempty(num_comparisons),  num_comparisons = numel(avg);  end
    if isempty(dof)
        if ~isscalar(avg) || ~isscalar(se)
            dof = max(numel(avg), numel(se)) - 1;
        else
            error('MATLAB:get_confpred_lim:emptyDof', 'Empty dof.');
        end
    end
    
    if isempty(avg) || isempty(se)
        lim  = zeros(0,2);
        conf = zeros(0,2);
        return;
    end
    
    if ~iscell(se),  se(se==0) = NaN;  end
    dof(dof<0) = NaN;
    
    conf = get_outlier_conf2 (num_comparisons, conf, multiple_correction_type);
    [prob, conf, tail] = get_prob (conf, tail);
    factor = arrayfun3(@(prob) tinv(prob, dof), prob);
    %factor = tinv(prob, dof);  % WRONG! error 'stats:tinv:InputSizeMismatch'

    se = get_confpred_lim_aux (se, dof, output_obs_or_mean, input_obs_or_mean);

    dim_avg = finddim(avg);  if (dim_avg ~= 1),  avg = avg.';  end
    dim_se  = finddim(se);   if (dim_se  ~= 1),  se  = se.';   end
    dim_dof = finddim(dof);  assert(dim_dof == 1);  % TODO: generalize.
    
    dlim = times_all(se, factor);
    lim = add_all(avg, dlim);
    
    switch lower(tail)  % (for consitency w/ stats vartest*)
    case 'right',  lim = [lim, +Inf(size(lim))];
    case 'left',   lim = [-Inf(size(lim)), lim];
    %case 'left',   lim = [zeros(size(lim)), lim];  % WRONG!
    case {'both','two','max'}  % do nothing else; see get_prob.m for details.
    end
    
    if (dim_avg ~= 1) || (dim_se ~= 1),  lim = lim.';  end
end
%#ok<*DEFNU>

%%
function se = get_confpred_lim_aux (s, dof, output_obs_or_mean, input_obs_or_mean)
    if strcmp(output_obs_or_mean, 'direct') ...
    && strcmp( input_obs_or_mean, 'direct')
      se = s;
      return
    end
    if isempty(output_obs_or_mean),  output_obs_or_mean = 'obs';  end
    if isempty( input_obs_or_mean),   input_obs_or_mean = 'obs';  end
     input_obs_or_mean = char( input_obs_or_mean);
    output_obs_or_mean = char(output_obs_or_mean);
     input_obs_or_mean = char( input_obs_or_mean);
    assert(any(strcmpi(output_obs_or_mean, {'obs','mean','avg'})))
    assert(any(strcmpi( input_obs_or_mean, {'obs','mean','avg'})))
    switch output_obs_or_mean
    case {'mean','avg'}
        assert(~iscell(s))
        switch input_obs_or_mean
        case {'mean','avg'},  se = s;
        case {'obs'},  se = s ./ sqrt(dof);
        end
    case {'obs'}
        if iscell(s)
            %assert(isempty(input_obs_or_mean))
            if isscalar(s),  se = cell2mat(s);  return;  end
            [se_mean, se_obs] = deal(s{:});
        else
            switch input_obs_or_mean
            case {'mean','avg'},  se_mean = s;  se_obs  = se_mean .* sqrt(dof);
            case {'obs'},      se_obs  = s;  se_mean = se_obs  ./ sqrt(dof);
            end            
        end
        se = sqrt(se_mean.^2 + se_obs.^2);
        % (see also nanstdur.m for a more general formulation.)
    end
end

%!test
%! % TODO: check for correctedness, not just consistency.
%! n = 100;
%! X = randn(n,1);
%! mean = 0;
%! se_obs = 1;
%! se_mean = se_obs / sqrt(n-1);
%! lim_a1 = get_confpred_lim (mean, se_obs, n-1, [], [], 'mean')
%! lim_a2 = get_confpred_lim (mean, se_mean, n-1, [], [], 'mean', 'mean')
%! lim_b1 = get_confpred_lim (mean, se_obs, n-1, [], [], 'obs')
%! lim_b2 = get_confpred_lim (mean, se_mean, n-1, [], [], 'obs', 'mean')
%! lim_b3 = get_confpred_lim (mean, {se_mean se_obs}, n-1, [], [], 'obs')
