function [bias, jacob] = snr_bias_poly_eval (coeff, indep, return_scalar)
    if (nargin < 2),  indep = [];  end
    if (nargin < 3) || isempty(return_scalar),  return_scalar = true;  end
    if (nargout > 1),  return_jacob = true;  else  return_jacob = false;  end
    if return_jacob,  return_scalar = false;  end
    if return_scalar
        % Return scalar bias if it's uniform across elev:
        switch numel(coeff)
        case 0,  bias = 0;  return;
        case 1,  bias = coeff;  return;
        otherwise,  % don't return;
        end
    end
    coeff = flip(coeff,2);  % (consistent with snr_bias_poly_fit):
    if (size(coeff,1) == numel(indep)) || isscalar(indep) || return_jacob
        [bias, jacob] = polyval1m(coeff, indep);
        jacob = flipdim(jacob,2);
    else
        assert(isvector(coeff) || isempty(coeff))
        bias = polyval(coeff, indep);
    end
end

