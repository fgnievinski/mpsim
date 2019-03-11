% make the covariance matrix numerically positive-definite:
function [cov2, chol2, tol] = make_cov_posdef (cov, varargin)
    [m,n]=size(cov);
    myassert(m==n);
    
    cov2 = cov;
    i = 0;
    while true
        try 
            chol2 = chol(cov2, varargin{:});
        catch
            i = i + 1;
            cov2 = cov + eps^(1/i) * eye(m);
            continue
        end
        break
    end
    disp(i)  % DEBUG
    % do it one last time:
    i = i + 1;
    cov2 = cov + eps^(1/i) * eye(m);
    if (nargout > 1),  chol2 = chol(cov2, varargin{:});  end
    %figure, imagesc(temp - cov), colorbar
    
    tol = sqrt(eps^(1/i));
end

