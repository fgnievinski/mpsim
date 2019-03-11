function [iparam, itime, icov, inum, istd0, resid] = smoothitvecwei (...
time, param, cov, dt, itime, ...
is_var_factor_global, ignore_nans, ignore_self, verbose)
%SMOOTHITVECWEI  Running average, with weighted vector input (full cov. matrices).

    is_var_factor_global_default = false;
    if (nargin < 6) || isempty(is_var_factor_global),  is_var_factor_global = is_var_factor_global_default;  end
    if (nargin < 7) || isempty(ignore_nans),  ignore_nans    = true;   end
    if (nargin < 8) || isempty(ignore_self),  ignore_self    = false;  end
    if (nargin < 9) || isempty(verbose),      verbose        = false;  end

    assert(isvector(itime));
    assert(isvector(time));
    ni = numel(itime);
    n = numel(time);
    m = size(param,2);
    %whos time param cov  % DEBUG
      myassert(size(cov), [m m n]);
      
    ind = (1:n)';
    idxn = any(isnan(param), 2) ...
         | squeeze(any(any(isnan(cov), 1), 2));
    ind(idxn) = NaN;  % honor ignore_nans
    
    iparam = NaN(ni,m);
    icov   = NaN(m,m,ni);
    resid  = NaN(n,m);
    if is_var_factor_global
        istd0  = NaN(ni,1);
    else
        istd0  = NaN(ni,m);
    end
    
    function inumk = g (timek, indk, itimek) %#ok<INUSL>
        % yi{k}(i,:) = f{k}(x(idx), y(idx,:), xi(i));
        paramk = param(indk,:);
        covk = cov(:,:,indk);
        [param_avg_k, cov_avg_k, istd0k, residk] = frontal_mean_vec_wei (...
            paramk, covk, is_var_factor_global);
        iidxk = (itime == itimek);
        if none(iidxk),  inumk = 0;  return;  end
        iparam(iidxk,:) = param_avg_k;
        icov(:,:,iidxk) = cov_avg_k;
        istd0(iidxk,:) = istd0k;
        resid(indk,:) = residk;
        inumk = numel(itimek);
    end
    %g(time(1), ind(1), ind(1))  % DEBUG

    input_x = true;
    return_as_cell = false;
    inum = smoothit (time, ind, dt, itime, @g, ...
        ignore_nans, input_x, ignore_self, return_as_cell, verbose);
end

%!test
%! % special case: non-moving vectorial weighted average.
%! for q=0:1,  is_var_factor_global = logical(q);
%! n = 5;
%! m = 3;
%! %time = (1:n)';
%! time = linspace(0, 1, n)';  % make it non-integer to stress test
%! param = rand(n,m);
%! cov = [];  for k=1:n,  cov = cat(3, cov, gallery('moler', m, rand()));  end
%! itime = 0;
%! dt = Inf;
%! iparam = smoothitvecwei (time, param, cov, dt, itime, is_var_factor_global);
%! iparam2 = frontal_mean_vec_wei (param, cov);
%! %iparam, iparam2, iparam-iparam  % DEBUG
%! myassert(iparam, iparam2, -sqrt(eps()))
%! end

%!test
%! % special case: moving non-correlated vectorial weighted average reduces to multiple scalar weighted averages.
%! for q=0:1,  is_var_factor_global = logical(q);
%! n = 5;
%! m = 3;
%! time = (1:n)';
%! param = rand(n,m);
%! std = abs(rand(n,m));
%! cov = frontal_diag(frontal_pt(std.^2));
%! itime = time(1:2:end);
%! dt = 3;
%! is_var_factor_global = false;
%! iparam = smoothitvecwei (time, param, cov, dt, itime, is_var_factor_global);
%! for j=1:m,  iparam2(:,j) = smoothitu (time, param(:,j), std(:,j), dt, itime);  end
%! %iparam, iparam2, iparam-iparam  % DEBUG
%! myassert(iparam, iparam2, -sqrt(eps()))
%! end
