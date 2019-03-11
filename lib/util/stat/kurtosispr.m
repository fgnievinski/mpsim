function kp = kurtosispr (kurt, var, dof, p, kurt0, var0, dof0, robustify)
%KURTOSISP  Pooled kurtosis.
%   For details,  please see:
%       D. G. Bonett (2006): Confidence interval for a ratio of variances
%       in bivariate nonnormal distributions, Journal of Statistical
%       Computation and Simulation, 76:07, 637-644, 
%       doi:10.1080/10629360500107733
% 
%   See also KURTOSISB, GET_VAR_LIM.

    if isempty(kurt),  kp = kurt;  return;  end
    if (nargin < 4) || isempty(p),  p = 1;  end
    if (nargin > 4) && (nargin <= 8) ...
    && ~isempty(kurt0) && ~isempty(var0) && ~isempty(var0)
        assert(isvector(kurt))
        assert(isscalar(kurt0))
        dim = finddim(kurt);
        assert(dim <= 2)
        switch dim
        case 1,  kurt(:,2) = kurt0;  var(:,2) = var0;  dof(:,2) = dof0;
        case 2,  kurt(2,:) = kurt0;  var(2,:) = var0;  dof(2,:) = dof0;
        end  
    end
    if (nargin < 8) || isempty(robustify),  robustify = true;  end
      
    N = dof + p;
    
    Nmc4 = kurt .* var.^2;
    if robustify,  mymeanw = @nanmeanw;  else  mymeanw = @nanmedianw;  end
    kp = mymeanw(Nmc4./var.^2, N);
    
    %mc4 = bsxfun(@rdivide, Nmc4, N);  % 4th central moment.
    %if robustify,  mysum = @nansumr;  else  mysum = @nansum;  end
    %kp = mysum(N) .* mysum(mc4) ./ mysum(var).^2;
    
    %if isnan(kp),  keyboard;  end  % DEBUG
end

%!test
%! % for large samples, the two should agree.
%! n = 100;
%! assert(iseven(n))
%! g = 4;
%! m = 1;
%! ekurt = -2:+2;
%! ekurt = [-2 0 +2];
%! ekurt = -1:+1;
%! %ekurt = 0  % DEBUG
%! kurt = ekurt + 3;
%! num_realiz = 10;
%! robustify = false;
%! robustify = true;
%! 
%! for i=1:numel(kurt)
%!   temp1 = [];
%!   temp2 = [];
%!   temp3 = [];
%!   for j=1:num_realiz
%!     x = pearsrnd(0,1,0,kurt(i),n,m);
%!     temp1(end+1,:) = kurtosis (x);
%! 
%!     y = mat2cell(x, repmat(n/g, [g 1]), m);
%!     cf = @(f) cellfun3(f, y);
%!     temp2(end+1,:) = kurtosispr (cf(@kurtosis), cf(@var), cf(@numel), 0);
%! 
%!     z = mat2cell(x, repmat(n/2, [2 1]), m);
%!     cf = @(f) cellfun3(f, z);
%!     temp3(end+1,:) = kurtosispr (...
%!       kurtosis(z{1}), var(z{1}), numel(z{1}), 0, ...
%!       kurtosis(z{2}), var(z{2}), numel(z{2}), robustify);
%!   end
%!   k1 = mean(temp1);
%!   k2 = mean(temp2);
%!   k3 = mean(temp3);
%! 
%!    fprintf('\n')
%!   disp(ekurt(i))
%!   [k1 - kurt(i);
%!    k2 - kurt(i);
%!    k3 - kurt(i)] %./kurt(i)*100
%!   [max(abs(k1 - kurt(i))) ...
%!    max(abs(k2 - kurt(i))) ...
%!    max(abs(k3 - kurt(i)))] %./kurt(i)*100
%!   [max(abs(k1 - k2)) ...
%!    max(abs(k1 - k3))] %./kurt(i)*100
%! end

