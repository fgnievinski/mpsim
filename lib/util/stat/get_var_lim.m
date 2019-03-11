function [lim, conf, instance] = get_var_lim (var, dof, kurt, var0, dof0, kurt0, ...
conf, tail, method, instance_requested, normalization_type, std_or_var, multiple_correction)
%GET_VAR_LIM  Confidence interval for the variance.
% 
% See also KURTOSISB, GET_PRED_LIM.
    nkurt = 3;  % normal kurtosis.
    if isempty(var) || isempty(dof)
        lim = zeros(0,2);
        conf = zeros(0,2);
        instance = char(zeros(0,2));
        return;
    end
    if (nargin < 3) || isempty(kurt),   kurt  = nkurt;  end
    if (nargin < 4) || isempty(var0),   var0  = 1;      end
    if (nargin < 5) || isempty(dof0),   dof0  = Inf;    end
    if (nargin < 6) || isempty(kurt0),  kurt0 = nkurt;  end
    if (nargin < 7),  conf = [];  end
    if (nargin < 8),  tail = [];  end
    if (nargin < 9),  method = [];  end
    if (nargin <10),  instance_requested = [];  end
    if (nargin <11) || isempty(normalization_type),  normalization_type = 'ratio';  end
    if (nargin <12) || isempty(std_or_var),  std_or_var = 'var';  end
    if (nargin <13),  multiple_correction = [];  end
    assert(any(strcmpi(std_or_var, {'std','var'})))
    if strcmpi(std_or_var, 'std'),  var = var.^2;  var0 = var0.^2;  end
    
    [argin, instance] = get_var_lim_argin (var, dof, kurt, var0, dof0, kurt0, ...
      method, instance_requested, nkurt);
    
    conf = get_outlier_conf2 (numel(var), conf, multiple_correction);
    [prob, conf, tail] = get_prob (conf, tail);
    fnc_name = ['get_var_lim_' strrep(instance, ' ', '_')];
    lim = feval(fnc_name, prob, argin{:});
    
    switch lower(normalization_type)
    case {'sample','none',''}
        % do nothing else.
    case {'population','inverted','invert'}
        lim = times_all(lim, var0./var);
    case {'sample over population','ratio'}
        lim = times_all(lim, 1./var0);
    case {'population over sample',}
        lim = 1./times_all(lim, 1./var0);
    otherwise
        error('MATLAB:get_val_lim:badNormalizationType', ...
            'Unrecognized normalization_type "%s".', normalization_type);
    end
    
    if strcmpi(std_or_var, 'std'),  lim = sqrt(lim);  end
    
    switch tail  % (for consitency w/ stats vartest*)
    case 'right',  lim = [lim, Inf(size(lim))];
    case 'left',   lim = [zeros(size(lim)), lim];
    %case 'left',   lim = [-Inf(size(lim)), lim];  % WRONG!
    end
end
%#ok<*DEFNU>

%%
function [argin, instance] = get_var_lim_argin (...
var, dof, kurt, var0, dof0, kurt0, method, instance_requested, nkurt)
    isnormal = all(kurt0 == nkurt) && all(kurt == nkurt);
    isknown  = all(dof0 == Inf);
    if (isnormal && isknown)
        instance_found = 'normal known';
    elseif (isnormal && ~isknown)
        instance_found = 'normal unknown';
    elseif (~isnormal && isknown)
        instance_found = 'nonnormal known';
    elseif (~isnormal && ~isknown)
        instance_found = 'nonnormal unknown';
    else
        error('MATLAB:get_val_lim:badInstance', 'Unrecognized instance.');
    end
    
    warn = true;
    warn = false;
    instance = instance_found;
    if ~isempty(instance_requested) && ~strcmp(instance_requested, instance_found)
        instance = instance_requested;
        if warn
            warning('MATLAB:get_val_lim:nonMatchingInstance', ...
                'Requested instance "%s" is taking precedence over the found one "%s"; ', ...
                instance_requested, instance_found);
        end
    end
    
    is_instance = @(instance_which) strcmp(instance_which, instance);
    %is_instance = @(instance_which) any(strcmp(instance_which, {instance_found, instance_requested}));
    if is_instance('normal known')
        argin = {var, dof};
    elseif is_instance('normal unknown')
        argin = {var, dof, var0, dof0};
    elseif is_instance('nonnormal known')
        argin = {var, dof, kurt, method};
    elseif is_instance('nonnormal unknown')
        argin = {var, dof, kurt, var0, dof0, kurt0, method};
    else
        error('MATLAB:get_val_lim:badInstance', 'Unrecognized instance.');
    end
end

%%
function lim = get_var_lim_normal_known (prob, var, dof) 
    fnc = @(prob) chi2inv(prob, dof)./dof;
    factor = arrayfun3(fnc, prob);
    lim = times_all(var, factor);
end

%%
function lim = get_var_lim_normal_unknown (prob, var, dof, var0, dof0)
    if isnan(dof0),  dof0 = nthroot(1/eps(),3);  end
    fnc = @(prob) finv(prob, dof, dof0);
    factor = arrayfun3(fnc, prob);
    lim = times_all(var, factor);
end

%%
function lim = get_var_lim_nonnormal_known (prob, var, dof, kurt, method)
    method_default = 3;  % seemed more reliable.
    %method_default = 4;
    if isempty(method),  method = method_default;  end
    fnc = @(prob) norminv(prob);
    factor = arrayfun3(fnc, prob);
    %N = n - p + 1;
    N = dof + 1;
    switch lower(method)
    case {1, 'kurtosis only', 'basic'}
        %temp = (kurt - 1)./N;
        temp = (kurt - 1)./(N - 1);
        temp = times_all(factor, sqrt(temp));
        lim = divide_all(var, 1 - temp);
    case {2, 'kurtosis and skewness', 'cramer delta'}
        %temp = (kurt - 1)./N;
        %temp = (kurt - 1)./(N - 1);
        temp = (kurt - (N - 3)./N)./(N - 1);
        temp = times_all(factor, sqrt(temp));
        lim = times_all(var, exp(temp));
    case {3, 'adjusted dof'}
        ekurt = kurt - 3;
        adof = 2 * N ./ (ekurt + 2 * N ./ (N - 1));
        adof = max(1, adof);
        fnc = @(prob) chi2inv(prob, adof)./adof;
        factor = arrayfun3(fnc, prob);
        lim = times_all(var, factor);
    case {4, 'bonnet'}
        k = (N - 3) ./ N;
        sesq = (kurt - k)./(N - 1);
        temp = times_all(factor, sqrt(sesq));
        c = N ./ ( N - factor .* (N - 2) ./ dof );
        lim = times_all(times_all(c, var), exp(times_all(c, temp)));
    otherwise
        error('MATLAB:get_val_lim:nonnormal_known:badMethod', ...
            'Unrecognized method "%s" for instance "nonnormal known".', ...
            method);
    end
    % <http://www.minitab.com/support/documentation/Answers/Assistant%20White%20Papers/1SampleStandardDeviation_MtbAsstMenuWhitePaper.pdf>
    % <http://courses.wcupa.edu/rbove/eco252/OneVariance.pdf>
    % <http://www.tandfonline.com/doi/pdf/10.1080/02664760500165339>
    if ~isreal(lim)
        warning('MATLAB:get_val_lim:nonReal', ...
            'Complex-valued result detected');
    end
end

%%
function lim = get_var_lim_nonnormal_unknown (prob, var1, dof1, kurt1, var0, dof0, kurt0, method)
    if isempty(method),  method = 1;  end
    N1 = dof1 + 1;
    N0 = dof0 + 1;
    switch lower(method)
    case {1, 'shoemaker'}
        get_adof = @(N, kurt) max(1, 2 * N ./ (kurt + (N - 3) ./ (N - 1)));
        adof1 = get_adof(N1, kurt1);
        adof0 = get_adof(N0, kurt0);
        adof1 =  ceil(adof1);
        adof0 = floor(adof0);
        if all(isfinite(adof0) & isfinite(dof0))
            lim = get_var_lim_normal_unknown (prob, var1, adof1, var0, adof0);
        else
            lim = get_var_lim_normal_known (prob, var1, adof1);
        end
    case {2, 'bonnet'}
        kurtp = kurtosisp (kurt1, var1, dof1, [], kurt0, var0, dof0);
        k1 = (N1 - 3) ./ N1;
        k0 = (N0 - 3) ./ N0;
        sesq = (kurtp - k1) ./ (N1 - 1) ...
             + (kurtp - k0) ./ (N0 - 1);
        fnc = @(prob) norminv(prob);
        factor = arrayfun3(fnc, prob);
        temp = times_all(factor, sqrt(sesq));
        c = (N1 ./ (N1 - factor)) ...
         ./ (N0 ./ (N0 - factor));
        lim = times_all(times_all(c, var1), exp(temp));
        %lim = times_all(times_all(c, var1), exp(times_all(c, temp)));
    otherwise
        error('MATLAB:get_val_lim:nonnormal_unknown:badMethod', ...
            'Unrecognized method "%s" for instance "nonnormal unknown".', ...
            method);
    end
    % <http://www.jstor.org/stable/pdfplus/30037243.pdf?acceptTC=true>
    % <http://apm.sagepub.com/content/30/5/432.full.pdf>
end

%%
%!test
%! instance = {...
%!   'normal known'
%!   'normal unknown'
%!   'nonnormal known'
%!   'nonnormal unknown'
%! };
%! method = {...
%!   {1, 2, 3}
%!   {1, 2, 3}
%!   num2cell(1:4)
%!   num2cell(1:2)
%! };
%! tail = {'both','right','left'};
%! %tail = {'left'};
%! %tail = {'right'};
%! tail = {'both'};
%! 
%! difficulty = 'easy';
%! %difficulty = 'medium';
%! %difficulty = 'hard';
%! switch difficulty
%! case 'easy'
%!   dof  = 250;
%!   kurt = 3+0;
%! case 'medium'
%!   dof  = 100;
%!   kurt = 3+1;
%! case 'hard'
%!   dof  = 10;
%!   kurt = 3+2;
%! end
%! conf = 0.95;
%! var  = 100;
%! var0 = 5;
%! num_realiz = 10;  % number of Monte Carlo realizations.
%! 
%! lim = {};
%! lab = {};
%! for i=1:numel(instance)
%! for j=1:numel(method{i})
%! for k=1:numel(tail)
%! for l=1:numel(kurt)
%!     varin  = var;
%!    var0in  = var0;
%!     dofin  = dof;
%!     dof0in = dof;
%!    kurtin  = kurt(l) + eps(kurt(l));
%!    kurt0in = kurt(l) + eps(kurt(l));
%!   switch instance{i}
%!   case 'normal known'
%!      dof0in = [];
%!     kurt0in = [];
%!     kurtin  = [];
%!   case 'normal unknown'
%!     dof0in  = NaN;  % special flag
%!     kurt0in = [];
%!     kurtin  = [];
%!   case 'nonnormal known'
%!      dof0in = [];
%!   case 'nonnormal unknown'
%!     % change nothing.
%!   end
%!   
%!   [lim{i,j,k,l}, ignore, instance_out] = get_var_lim (...
%!      varin,  dofin,  kurtin, ...
%!     var0in, dof0in, kurt0in, ...
%!     conf, tail{k}, method{i}{j});
%!   lab{i,j,k,l} = sprintf('%s %d %s %+g', instance{i}, method{i}{j}, tail{k}, kurt(l)-3);
%!   assert(strcmp(instance_out, instance{i}))
%!   
%!   if ~isempty(strfind(instance{i}, 'nonnormal')) ...
%!   || ~ismember(method{i}{j}, [2 3])
%!     continue;
%!   end
%!   temp = [];
%!   for m=1:num_realiz
%!     if (method{i}{j} == 2)
%!       x =  normrnd(0,sqrt(var),          dof+1,1);
%!     else
%!       x = pearsrnd(0,sqrt(var),0,kurt(l),dof+1,1);
%!     end
%!     switch instance{i}
%!     case 'normal known'
%!       [H,P,CI,STATS] = vartest(x,var0,1-conf,tail{k});
%!       %temp(end+1,:) = CI;  %WRONG!
%!       temp(end+1,:) = CI ./ var0;  % vartest's CI refers to x's variance.
%!     case 'normal unknown'
%!       if (method{i}{j} == 2)
%!         y =  normrnd(0,sqrt(var0),          dof+1,1);
%!       else
%!         y = pearsrnd(0,sqrt(var0),0,kurt(l),dof+1,1);
%!       end
%!       [H,P,CI,STATS] = vartest2(x,y,1-conf,tail{k});
%!       %keyboard  % DEBUG
%!       temp(end+1,:) = CI;
%!     end
%!   end
%!   lim{i,j,k,l} = mean(temp, 1);
%! end
%! end
%! end
%! end
%! %#ok<*SAGROW>
%! lim = lim';
%! lab = lab';
%! 
%! %%
%! %cprintf(num2cell(cell2mat([lim(:), ref(:)])), '-Lr',lab(~cellfun(@isempty, lab)))
%! cprintf(num2cell(cell2mat(lim(:))), '-Lr',lab(~cellfun(@isempty, lab)))
%! 
